{self, ...}: {
  flake.nixosModules.Firefox = {
    pkgs,
    inputs,
    lib,
    config,
    ...
  }: let
    jail = import ../../lib/_jail.nix {inherit pkgs inputs;};

    moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";

    addons = {
      "uBlock0@raymondhill.net" = "ublock-origin";
      "CanvasBlocker@kkapsner.de" = "canvasblocker";
      "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
      "{2adf0361-e6d8-4b74-b3bc-3f450e8ebb69}" = "catppuccin-mocha-blue-git";
    };

    legitShortener = "https://github.com/DandelionSprout/adfilt/raw/master/LegitimateURLShortener.txt";

    adminSettings = {
      userSettings = {
        uiTheme = "dark";
        uiAccentCustom = true;
        uiAccentCustom0 = "#89b4fa";
        cloudStorageEnabled = false;
        advancedUserEnabled = true;
        importedLists = [legitShortener];
        externalLists = legitShortener;
      };

      selectedFilterLists = [
        "ublock-filters"
        "ublock-badware"
        "ublock-privacy"
        "ublock-unbreak"
        "ublock-quick-fixes"
        "easylist"
        "easyprivacy"
        "urlhaus-1"
        legitShortener
      ];

      hostnameSwitchesString = "no-csp-reports: * true\nno-large-media: behind-the-scene false\n";
    };

    extensionSettings =
      lib.listToAttrs
      (lib.mapAttrsToList
        (id: slug:
          lib.nameValuePair id {
            install_url = moz slug;
            installation_mode = "force_installed";
            updates_disabled = true;
          })
        addons)
      // {
        "*".installation_mode = "blocked";
      };

    uBlockAdminSettings = {
      Extensions."uBlock0@raymondhill.net".adminSettings = adminSettings;
    };

    policies = {
      AppAutoUpdate = false;
      BackgroundAppUpdate = false;

      # No phoning home
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      UserMessaging = {
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        UrlbarInterventions = false;
        SkipOnboarding = true;
        MoreFromMozilla = false;
        FirefoxLabs = false;
        Locked = true;
      };

      # no AI
      GenerativeAI = {
        Enabled = false;
        Chatbot = false;
        LinkPreviews = false;
        TabGroups = false;
        Locked = true;
      };

      AIControls = let
        blocked = {
          Value = "blocked";
          Locked = true;
        };
      in {
        Default = blocked;
        Translations = blocked;
        PDFAltText = blocked;
        SmartTabGroups = blocked;
        LinkPreviewKeyPoints = blocked;
        SidebarChatbot = blocked;
        SmartWindow = blocked;
      };

      TranslateEnabled = false;
      IPProtectionAvailable = false;

      HttpsOnlyMode = "force_enabled";
      DNSOverHTTPS = {
        Enabled = false; # I use ProtonVPN
        Fallback = true;
        Locked = true;
      };

      EnableTrackingProtection = {
        Category = "strict";
        BaselineExceptions = true;
        ConvenienceExceptions = false;
        Locked = true;
      };

      SanitizeOnShutdown = {
        Cache = true;
        Cookies = true;
        FormData = true;
        History = true;
        Sessions = true;
        SiteSettings = false;
        Exceptions = config.nixcfgs.firefox_cookie_allowlist;
        Locked = true;
      };

      NoDefaultBookmarks = true;
      NewTabPage = false;

      FirefoxHome = {
        Search = false;
        TopSites = false;
        SponsoredTopSites = false;
        Highlights = false;
        Pocket = false;
        SponsoredPocket = false;
        Stories = false;
        SponsoredStories = false;
        Snippets = false;
        Locked = true;
      };

      FirefoxSuggest = {
        WebSuggestions = false;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
        Locked = true;
      };

      Homepage = {
        StartPage = "none";
        Locked = true;
      };

      # Passwords are handled by Bitwarden (better)
      PasswordManagerEnabled = false;
      OfferToSaveLogins = false;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;

      # random bloat
      DisableBuiltinPDFViewer = true;
      DisableFirefoxAccounts = true;
      DisableFirefoxScreenshots = true;
      DisableForgetButton = true;
      DisableMasterPasswordCreation = true;
      DisablePasswordReveal = true;
      DisableProfileImport = true;
      DisableProfileRefresh = true;
      DisableSetDesktopBackground = true;
      DisablePocket = true;
      DisableFormHistory = true;

      # Disallow tampering
      BlockAboutConfig = true;
      BlockAboutProfiles = true;
      BlockAboutSupport = false;
      InstallAddonsPermission.Default = false;

      DisplayMenuBar = "never";
      DontCheckDefaultBrowser = true;
      HardwareAcceleration = true;
      DefaultDownloadDirectory = "/home/${config.nixcfgs.username}/Downloads";

      Extensions.Locked = lib.attrNames addons;
      ExtensionSettings = extensionSettings;
      "3rdparty" = uBlockAdminSettings;
    };
  in {
    environment.systemPackages = [
      (jail.mkSandboxed (pkgs.firefox.override {extraPolicies = policies;}) "firefox"
        (with jail.combinators; [
          default
          network
          (dbus {own = ["org.mpris.MediaPlayer2.firefox" "org.mpris.MediaPlayer2.firefox.*"];})
          (rw-bind (noescape "~/.cache/mozilla") (noescape "~/.cache/mozilla"))
          (rw-bind (noescape "~/.config/mozilla") (noescape "~/.config/mozilla"))
          (rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))
          (
            if config.nixcfgs.firefox_full_dev_access
            then (unsafe-add-raw-args "--dev-bind /dev /dev")
            else
              compose (lib.genList (i: unsafe-add-raw-args "--dev-bind /dev/hidraw${toString i} /dev/hidraw${toString i}") 9)
              ++ [(readonly (noescape "/sys/class/hidraw")) (readonly (noescape "/sys/devices/pci0000:00"))]
          )
        ]))
    ];
  };
}
