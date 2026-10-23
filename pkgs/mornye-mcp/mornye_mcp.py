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


@mcp.tool()
def mornye_info() -> dict[str, Any]:
    """Version, auth state and multiuser flag of this Mornye instance."""
    return _request("GET", "/api/v1/info")


@mcp.tool()
def mornye_search(q: str, limit: int = 20) -> dict[str, Any]:
    """Search the metadata catalogue for tracks matching q."""
    return _request("GET", "/api/v1/search", params={"q": q, "limit": limit})


@mcp.tool()
def mornye_search_provider(provider: str, query: str) -> dict[str, Any]:
    """Search a catalogue extension by provider/source id (e.g. tidal-web)."""
    return _request(
        "POST",
        "/api/search_provider",
        body={"query": query, "source": provider},
    )


@mcp.tool()
def mornye_resolve(url: str) -> dict[str, Any]:
    """Resolve an album/playlist/track URL to its tracklist; downloads nothing."""
    return _request("POST", "/api/v1/resolve", body={"url": url})


@mcp.tool()
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


@mcp.tool()
def mornye_job(job_id: str) -> dict[str, Any]:
    """Status, error and payload of one download job."""
    return _request("GET", f"/api/v1/downloads/{job_id}")


@mcp.tool()
def mornye_jobs() -> dict[str, Any]:
    """List the download jobs this instance still knows about."""
    return _request("GET", "/api/v1/downloads")


@mcp.tool()
def mornye_cancel(job_id: str) -> dict[str, Any]:
    """Cancel a queued or running download job."""
    return _request("POST", f"/api/v1/downloads/{job_id}/cancel")


@mcp.tool()
def mornye_extensions() -> dict[str, Any]:
    """Installed extensions with their reliability history."""
    return _request("GET", "/api/v1/extensions")


@mcp.tool()
def mornye_signed_sessions() -> dict[str, Any]:
    """List cached provider signed sessions and their expiry (secrets omitted)."""
    return _request("POST", "/api/get_signed_sessions")


@mcp.tool()
def mornye_prune_signed_sessions() -> dict[str, Any]:
    """Drop cached signed sessions whose provider no longer needs them."""
    return _request("POST", "/api/prune_signed_sessions")


@mcp.tool()
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
