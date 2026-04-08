{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ii-material-sddm";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "ToRvaLDz";
    repo = "ii-material-sddm";
    rev = "v${finalAttrs.version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    local themeDir="$out/share/sddm/themes/ii-material-sddm"
    install -d "$themeDir/Components" "$themeDir/Backgrounds"
    install -m644 Main.qml metadata.desktop theme.conf translations.js "$themeDir/"
    install -m644 colors.json "$themeDir/" 2>/dev/null || true
    install -m644 Components/*.qml "$themeDir/Components/"
    install -m644 Backgrounds/* "$themeDir/Backgrounds/" 2>/dev/null || true
    install -m644 preview.png "$themeDir/" 2>/dev/null || true
    runHook postInstall
  '';

  meta = {
    description = "Material Design 3 SDDM theme inspired by the ii lockscreen from end-4/dots-hyprland";
    homepage = "https://github.com/ToRvaLDz/ii-material-sddm";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
