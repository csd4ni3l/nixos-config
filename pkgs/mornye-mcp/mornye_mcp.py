"""Stdio MCP backend for the Mornye HTTP API.

Mornye takes its token as a `?token=` query parameter, never a bearer
header, so every request appends it. API surface is /api/v1 plus the two
dispatcher calls that still live on /api/{method}.
"""

from __future__ import annotations

import asyncio
import os
import sys
from typing import Any

import httpx
from mcp.server.mcpserver import MCPServer

DEFAULT_URL = "http://127.0.0.1:64500"
TOKEN_ENV = "MORNYE_WEB_TOKEN"
TIMEOUT = httpx.Timeout(60.0, connect=5.0)

mcp = MCPServer("mornye")


def _config() -> tuple[str, str]:
    token = os.environ.get(TOKEN_ENV, "").strip()
    if not token:
        raise RuntimeError(
            f"{TOKEN_ENV} is required (mcp-gateway passes it from the "
            "'mornye-web-token' sops secret)"
        )
    return os.environ.get("MORNYE_URL", DEFAULT_URL).rstrip("/"), token


def _request(
    method: str,
    path: str,
    *,
    params: dict[str, Any] | None = None,
    body: dict[str, Any] | None = None,
) -> dict[str, Any]:
    """Call Mornye and turn transport/HTTP failures into a dict error."""
    try:
        url, token = _config()
    except RuntimeError as exc:
        return {"error": str(exc), "status": None}

    query = dict(params or {})
    query["token"] = token

    try:
        with httpx.Client(timeout=TIMEOUT) as client:
            response = client.request(
                method, f"{url}{path}", params=query, json=body
            )
    except httpx.HTTPError as exc:
        return {"error": f"{type(exc).__name__}: {exc}", "status": None}

    try:
        payload: Any = response.json()
    except ValueError:
        payload = {"body": response.text[:2000]}

    if response.status_code >= 400:
        detail = payload.get("error") if isinstance(payload, dict) else None
        if detail is None and isinstance(payload, dict):
            detail = payload.get("detail", payload)
        return {"error": str(detail), "status": response.status_code}

    return payload if isinstance(payload, dict) else {"result": payload}


_TITLE_KEYS = ("title", "name")
_ARTIST_KEYS = ("artists", "artist")
_ALBUM_KEYS = ("album", "album_name")
_URL_KEYS = ("external_url", "external_urls")
_TRACK_LIST_KEYS = ("tracks", "results", "items", "data", "tracklist")
# The legacy /api/{method} dispatcher wraps every answer in {"result": ...},
# hiding the tracklist from the compaction below.
_CONTAINER_KEYS = ("result",)
_ENTITY_LIST_KEYS = (
    *_TRACK_LIST_KEYS,
    "albums",
    "artists",
    "playlists",
)


def _first(data: dict[str, Any], keys: tuple[str, ...]) -> Any:
    for key in keys:
        value = data.get(key)
        if value not in (None, "", [], {}):
            return value
    return None


def _put(compact: dict[str, Any], key: str, value: Any) -> None:
    if value not in (None, "", [], {}):
        compact[key] = value


def _with_ids(item: dict[str, Any], compact: dict[str, Any]) -> dict[str, Any]:
    for key in ("id", "provider"):
        _put(compact, key, item.get(key))
    _put(compact, "url", _first(item, _URL_KEYS))
    return compact


def _compact_track(track: Any) -> Any:
    if not isinstance(track, dict):
        return track

    artists = _first(track, _ARTIST_KEYS)
    if isinstance(artists, list):
        artists = ", ".join(str(a) for a in artists)

    compact: dict[str, Any] = {}
    _put(compact, "title", _first(track, _TITLE_KEYS))
    _put(compact, "artist", artists)
    _put(compact, "album", _first(track, _ALBUM_KEYS))

    duration_ms = track.get("duration_ms")
    if isinstance(duration_ms, (int, float)) and duration_ms > 0:
        seconds = int(duration_ms) // 1000
        compact["duration"] = f"{seconds // 60}:{seconds % 60:02d}"

    return _with_ids(track, compact)


def _compact_album(album: Any) -> Any:
    if not isinstance(album, dict):
        return album

    compact: dict[str, Any] = {}
    _put(compact, "title", _first(album, _TITLE_KEYS))
    _put(compact, "artist", _first(album, _ARTIST_KEYS))
    _put(compact, "released", album.get("release_date"))
    return _with_ids(album, compact)


def _compact_artist(artist: Any) -> Any:
    if not isinstance(artist, dict):
        return artist

    compact: dict[str, Any] = {}
    _put(compact, "name", _first(artist, _TITLE_KEYS))
    return _with_ids(artist, compact)


def _compact_playlist(playlist: Any) -> Any:
    if not isinstance(playlist, dict):
        return playlist

    compact: dict[str, Any] = {}
    _put(compact, "name", _first(playlist, _TITLE_KEYS))
    _put(compact, "owner", playlist.get("owner"))
    return _with_ids(playlist, compact)


def _compact_entity(item: Any) -> Any:
    if not isinstance(item, dict):
        return item

    kind = str(item.get("type") or "").lower()
    if kind == "album":
        return _compact_album(item)
    if kind == "artist":
        return _compact_artist(item)
    if kind == "playlist":
        return _compact_playlist(item)
    return _compact_track(item)


def _compact(payload: Any) -> Any:
    if isinstance(payload, list):
        return [_compact_entity(item) for item in payload]
    if not isinstance(payload, dict):
        return payload

    # Unwrap the legacy dispatcher envelope so callers see the same shape as
    # /api/v1 answers instead of {"result": {...}}.
    if set(payload) == {"result"}:
        return _compact(payload["result"])

    result = dict(payload)
    for key in (*_CONTAINER_KEYS, *_ENTITY_LIST_KEYS):
        if isinstance(result.get(key), list):
            result[key] = [_compact_entity(item) for item in result[key]]
        elif isinstance(result.get(key), dict):
            result[key] = _compact(result[key])
    result.pop("trace_id", None)
    return result


@mcp.tool(structured_output=False)
def mornye_info() -> dict[str, Any]:
    """Version, auth state and multiuser flag of this Mornye instance."""
    return _request("GET", "/api/v1/info")


@mcp.tool(structured_output=False)
def mornye_search(q: str, limit: int = 20) -> dict[str, Any]:
    """Search the metadata catalogue for tracks matching q."""
    return _compact(
        _request("GET", "/api/v1/search", params={"q": q, "limit": limit})
    )


@mcp.tool(structured_output=False)
def mornye_search_provider(
    provider: str, query: str, limit: int = 10
) -> dict[str, Any]:
    """Search a catalogue extension by provider/source id (e.g. tidal-web)."""
    return _compact(
        _request(
            "POST",
            "/api/search_provider",
            body={"query": query, "source": provider, "limit": limit},
        )
    )


@mcp.tool(structured_output=False)
def mornye_resolve(url: str) -> dict[str, Any]:
    """Resolve an album/playlist/track URL to its tracklist; downloads nothing."""
    return _compact(
        _request("POST", "/api/v1/resolve", body={"url": url})
    )


@mcp.tool(structured_output=False)
def mornye_download(
    url: str,
    quality: str = "LOSSLESS",
    services: list[str] | None = None,
    output_dir: str | None = None,
) -> dict[str, Any]:
    """Queue a download (202 + job id); LOSSLESS only, never HI_RES."""
    tier = quality.strip().upper()
    if tier.startswith("HI_RES") or tier == "DOLBY_ATMOS":
        return {
            "error": (
                "Refusing HI_RES*/DOLBY_ATMOS: this library is 16-bit FLAC "
                "only. Use quality='LOSSLESS'."
            ),
            "status": 400,
        }

    body: dict[str, Any] = {"url": url, "quality": tier}
    if services:
        body["services"] = services
    if output_dir:
        body["output_dir"] = output_dir
    return _request("POST", "/api/v1/downloads", body=body)


@mcp.tool(structured_output=False)
def mornye_job(job_id: str) -> dict[str, Any]:
    """Status, error and payload of one download job."""
    return _request("GET", f"/api/v1/downloads/{job_id}")


@mcp.tool(structured_output=False)
def mornye_jobs() -> dict[str, Any]:
    """List the download jobs this instance still knows about."""
    return _request("GET", "/api/v1/downloads")


@mcp.tool(structured_output=False)
def mornye_cancel(job_id: str) -> dict[str, Any]:
    """Cancel a queued or running download job."""
    return _request("POST", f"/api/v1/downloads/{job_id}/cancel")


@mcp.tool(structured_output=False)
def mornye_extensions() -> dict[str, Any]:
    """Installed extensions with their reliability history."""
    return _request("GET", "/api/v1/extensions")


@mcp.tool(structured_output=False)
def mornye_signed_sessions() -> dict[str, Any]:
    """List cached provider signed sessions and their expiry (secrets omitted)."""
    return _request("POST", "/api/get_signed_sessions")


@mcp.tool(structured_output=False)
def mornye_prune_signed_sessions() -> dict[str, Any]:
    """Drop cached signed sessions whose provider no longer needs them."""
    return _request("POST", "/api/prune_signed_sessions")


@mcp.tool(structured_output=False)
def mornye_get_download_services() -> dict[str, Any]:
    """List the download providers this install can actually offer: one row
    per service with `id` (a bare provider name such as "deezer" or
    "qobuz-web"), `label`, and the installed extension ids behind it. Use
    these ids in `mornye_download(services=[...])`."""
    return _request("POST", "/api/get_download_services")


@mcp.tool(structured_output=False)
def mornye_clear_signed_session(key: str) -> dict[str, Any]:
    """Drop one signed session's credentials (key as shown by
    `mornye_signed_sessions`) so the next request verifies again. This does
    NOT clear the auth backoff pause: a session with auth_paused_s > 0
    still waits out its pause unless the matching .auth-backoff.json file is
    removed from the sessions directory."""
    return _request("POST", "/api/clear_signed_session", body={"key": key})


@mcp.tool(structured_output=False)
def mornye_node_status() -> dict[str, Any]:
    """Whether the Node.js runtime used by JavaScript extensions is available
    and its version. A failed check means no extension can run."""
    return _request("POST", "/api/get_node_status")


@mcp.tool(structured_output=False)
def mornye_library_scan() -> dict[str, Any]:
    """Find files below LOSSLESS quality in /downloads (read-only)."""
    return _request(
        "POST",
        "/api/v1/library/scan",
        body={
            "path": "/downloads",
            "target_quality": "LOSSLESS",
            "recursive": True,
            "verify_hires": False,
        },
    )


def main() -> None:
    if "--list-tools" in sys.argv[1:]:
        for tool in asyncio.run(mcp.list_tools()):
            print(f"{tool.name}: {tool.description}")
        return

    try:
        _config()
    except RuntimeError as exc:
        print(f"mornye-mcp: {exc}", file=sys.stderr)
        raise SystemExit(2) from exc

    mcp.run()


if __name__ == "__main__":
    main()
