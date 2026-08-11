{inputs, ...}: {
  programs.firefox = {
    enable = true;

    package = null;

    profiles.default = {
      id = 0;
      isDefault = true;
      path = "default";

      # NOTE: acknowledge the catppuccin module's FirefoxColor theme settings
      extensions.force = true;

      search = {
        force = true;
        default = "DuckDuckGo (HTML)";
        privateDefault = "DuckDuckGo (HTML)";

        engines."DuckDuckGo (HTML)" = {
          urls = [
            {
              template = "https://html.duckduckgo.com/html/";
              params = [
                {
                  name = "q";
                  value = "{searchTerms}";
                }
              ];
            }
          ];

          icon = "https://duckduckgo.com/favicon.ico";
          definedAliases = ["@ddg"];
        };
      };

      extraConfig =
        builtins.readFile "${inputs.arkenfox}/user.js"
        + ''
          // Custom settings

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

          // GPC/DNT makes you more trackable, as 90% of browsers don't use it
          user_pref("privacy.globalprivacycontrol.enabled", false);
          user_pref("privacy.donottrackheader.enabled", false);

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

          // networking
          user_pref("network.prefetch-next", false);
          user_pref("network.IDN_show_punycode", true);
          user_pref("network.dns.echconfig.enabled", true);

          // history on, purged at shutdown by enterprise policy
          user_pref("places.history.enabled", true);

          // dark theme
          user_pref("ui.systemUsesDarkTheme", 1);
        '';
    };
  };
}
