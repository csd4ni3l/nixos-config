{...}: {
  systems = ["x86_64-linux"];
  perSystem = {pkgs, ...}: {
    packages.dmemcg-booster = pkgs.callPackage ../pkgs/dmemcg-booster {};
    packages.pelican-wings = pkgs.callPackage ../pkgs/wings {};
    packages.fluxer-canary = pkgs.callPackage ../pkgs/fluxer-canary {};

    # ArtCraft App Suite, (checking if this works out, if not, then i will remove it)
    packages.craft-wordcraft = pkgs.callPackage ../pkgs/craft {
      pname = "wordcraft";
      version = "0.6.1";
      hash = "sha256:1y9qrajxgbwfwg7dx0aqrfsal3jyq7g2lhr229aymxkn2b459gbr";
    };
    packages.craft-deckcraft = pkgs.callPackage ../pkgs/craft {
      pname = "deckcraft";
      version = "0.6.1";
      hash = "sha256:0sbmy69i3b2qnphwqqqxvrlpd6n3a67hgqpgwfdm4s5a257yc58j";
    };
    packages.craft-gridcraft = pkgs.callPackage ../pkgs/craft {
      pname = "gridcraft";
      version = "0.6.1";
      hash = "sha256:0i972qh480m83xwxh0yaf8daf463bp8mbcp1cjw19y7sv5i3n5k1";
    };
    packages.craft-pdfcraft = pkgs.callPackage ../pkgs/craft {
      pname = "pdfcraft";
      version = "0.7.1";
      hash = "sha256:05d3cxb2r7gk37vaz83nqnvcrpf4nbahvgnclpv20dr724anazdw";
    };
    packages.craft-vectorcraft = pkgs.callPackage ../pkgs/craft {
      pname = "vectorcraft";
      version = "0.10.0";
      hash = "sha256:1z56bacx5isgx7cdvva8791hafm7yw29a1n3nk4khw47jahkamx5";
    };
  };
}
