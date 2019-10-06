self: super:

let
  unstable = import <nixos-unstable> { overlays = []; };
  shared = self.callPackage <dotfiles/shared> {};

  rust = self.latest.rustChannels.stable.rust;
  rustPlatform = self.makeRustPlatform {
    cargo = rust;
    rustc = rust;
  };

  rustSoftware = (
    { from ? null, name, src, hash, extra ? {} }:
    rustPlatform.buildRustPackage (builtins.foldl' (x: y: x // y) {} [
      (if from == null
        then {}

        # Inherit these attribute, *if* they exist
        else (builtins.intersectAttrs {
          buildInputs = null;
          cargoBuildFlags = null;
          meta = null;
          nativeBuildInputs = null;
          postFixup = null;
          #postInstall = null;
        } from)
      )

      ({
        name = "${name}-local";
        src = shared.utils.cleanSource src;
        cargoSha256 = hash;
        doCheck = false;
      })

      extra
    ])
  );
in {
  termplay = rustSoftware {
    from = unstable.termplay;
    name = "termplay";
    src = ~/Coding/Rust/termplay;
    hash = "0nr4xii09z6djdj9586b5mpncp7n3xlng65czz3g777ylwj0f7v2";
  };
  # xidlehook is currently going through some rewriting and is not
  # stable enough for me to use yet.
  #
  # xidlehook = rustSoftware rec {
  #   from = unstable.xidlehook;
  #   name = "xidlehook";
  #   src = ~/Coding/Rust/xidlehook;
  #   hash = "0van6s1f6kqdjxgmzcx3k6c7f1ap4dfcvxh19fad656mprc60pb2";
  #   extra = {
  #       buildInputs = with self; [ xorg.xlibsWrapper xorg.libXScrnSaver libpulseaudio ];
  #       nativeBuildInputs = from.nativeBuildInputs ++ (with self; [ python3 ]);
  #       cargoBuildFlags = ["--bins"];
  #   };
  # };
  powerline-rs = rustSoftware {
    from = unstable.powerline-rs;
    name = "powerline-rs";
    src = ~/Coding/Rust/powerline-rs;
    hash = "1sr9vbfk5bb3n0lv93y19in1clyvbj0w3p1gmp4sbw8lx84zwxhc";
  };
}
