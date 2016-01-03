{ stdenv, fetchgit, fetchurl, writeText
, qt4, protobuf, libpcap
, wireshark, gzip, diffutils, gawk
}:

stdenv.mkDerivation {
  name = "ostinato-2015-12-24";
  src = fetchgit {
    url = "https://github.com/pstavirs/ostinato.git";
    rev = "414d89860de0987843295d149bcabeac7c6fd9e5";
    sha256 = "0hb78bq51r93p0yr4l1z5xlf1i666v5pa3zkdj7jmpb879kj05dx";
  };

  buildInputs = [ qt4 protobuf libpcap ];

  patches = [ ./drone_ini.patch ];

  configurePhase = "qmake PREFIX=$out"
    + stdenv.lib.optionalString stdenv.isDarwin " -spec macx-g++";

  postInstall = ''
    cat > $out/bin/ostinato.ini <<EOF
    WiresharkPath=${wireshark}/bin/wireshark
    TsharkPath=${wireshark}/bin/tshark
    GzipPath=${gzip}/bin/gzip
    DiffPath=${diffutils}/bin/diff
    AwkPath=${gawk}/bin/awk
    EOF

    mkdir -p $out/share/pixmaps
    install -D -m 644 ${./ostinato.png} $out/share/pixmaps/ostinato.png

    # Create a desktop item.
    mkdir -p $out/share/applications
    cat > $out/share/applications/ostinato.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Encoding=UTF-8
    Name=Ostinato
    GenericName=Packet/Traffic Generator and Analyzer
    GenericName[it]=Generatore ed Analizzatore di pacchetti di rete
    Comment=Network packet and traffic generator and analyzer with a friendly GUI
    Comment[it]=Generatore ed Analizzatore di pacchetti di rete con interfaccia amichevole
    Icon=$out/share/pixmaps/ostinato.png
    Exec=$out/bin/ostinato
    Terminal=false
    Categories=Network;
    StartupNotify=true
    EOF
  '';

  meta = with stdenv.lib; {
    description = "A packet traffic generator and analyzer";
    homepage = http://ostinato.org;
    license = licenses.gpl3;
    maintainers = with maintainers; [ rick68 ];
    platforms = platforms.linux;  # also OS X and cygwin
  };
}
