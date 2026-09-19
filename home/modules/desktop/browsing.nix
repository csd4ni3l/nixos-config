{inputs, ...}: {
  programs.firefox = {
    enable = true;
    package = null;
    profiles.default = {
      id = 0;
      isDefault = true;
      path = "default";
      search = {
        force = true;
        default = "degoog";
        privateDefault = "degoog";
        engines."degoog" = {
          urls = [
            {
              template = "https://search.home.csd4ni3l.hu/search";
              params = [
                {
                  name = "q";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          icon = "https://search.home.csd4ni3l.hu/favicon.ico";
          definedAliases = ["@dg"];
        };
      };
      extraConfig =
        builtins.readFile "${inputs.arkenfox}/user.js"
        + ''
          // urlbar stuff
          user_pref("browser.search.suggest.enabled", false);
          user_pref("browser.urlbar.suggest.searches", false);
          user_pref("browser.urlbar.suggest.bookmark", false);
          user_pref("browser.urlbar.suggest.topsites", false);
          user_pref("browser.urlbar.suggest.engines", false);
          user_pref("browser.urlbar.suggest.history", true);
          user_pref("browser.urlbar.quicksuggest.enabled", false);
          user_pref("browser.urlbar.quicksuggest.sponsoredEnabled", false);
          user_pref("browser.urlbar.quicksuggest.nonSponsoredEnabled", false);
          user_pref("browser.urlbar.quicksuggest.dataCollection.enabled", false);

          // extra OPSEC or whatever
          user_pref("permissions.memory_only", true);
          user_pref("security.nocertdb", true);
          user_pref("browser.download.forbid_open_with", true);
          user_pref("dom.popup_allowed_events", "click dblclick mousedown pointerdown");
          user_pref("javascript.options.asmjs", false);

          // ew DRM
          user_pref("media.eme.enabled", false);
          user_pref("media.eme.ui.enabled", false);

          // password manager and autofill off (Bitwarden handles it)
          user_pref("signon.rememberSignons", false);
          user_pref("signon.autofillForms", false);
          user_pref("signon.storeWhenAutocompleteOff", false);
          user_pref("extensions.formautofill.addresses.enabled", false);
          user_pref("extensions.formautofill.creditCards.enabled", false);

          // no phoning home
          user_pref("extensions.htmlaboutaddons.recommendations", false);
          user_pref("browser.discovery.enabled", false);
          user_pref("browser.send_pings", false);
          user_pref("browser.translations.automaticallyPopup", false);
          user_pref("browser.sessionstore.resume_from_crash", false);
          user_pref("browser.tabs.crashReporting.sendReport", false);
          user_pref("browser.pagethumbnails.capturing_disabled", true);
          user_pref("browser.region.update.enabled", false);
          user_pref("browser.region.network.url", "");
          user_pref("geo.provider.network.url", "");

          // networking
          user_pref("network.prefetch-next", false);
          user_pref("network.IDN_show_punycode", true);
          user_pref("network.dns.echconfig.enabled", true);

          // history on, purged at shutdown by enterprise policy
          user_pref("places.history.enabled", true);

          // Anti-fingerprinting
          user_pref("privacy.resistFingerprinting", true);
          user_pref("privacy.resistFingerprinting.pbmode", true);
          user_pref("privacy.resistFingerprinting.letterboxing", true);
          user_pref("privacy.resistFingerprinting.skipEarlyBlankFirstPaint", true);
          user_pref("privacy.spoof_english", 2);
          user_pref("intl.accept_languages", "en-US, en");

          // automatically reject cookies
          user_pref("cookiebanners.service.mode", 2);
          user_pref("cookiebanners.service.mode.privateBrowsing", 2);

          user_pref("browser.ml.enable", false);
          user_pref("browser.ml.chat.enabled", false);
          user_pref("extensions.ml.enabled", false);
        '';
    };
  };
}
