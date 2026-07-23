{ pkgs, ... }: {
  home.packages = with pkgs; [
    # hacking
    metasploit
    nmap
    ffuf
    gobuster
    sqlmap
    john
    socat
    nikto
    hashcat
    tcpdump
    wireshark
    iw
    xterm
    aircrack-ng
    bully
    netexec
    theharvester
    exploitdb
    smbmap
    arp-scan
    enum4linux
    enum4linux-ng
    dnsrecon
    testssl
    thc-hydra
    whatweb
    evil-winrm
    crunch
    hashcat-utils
    cadaver
    wpscan
    certipy
    coercer
    gomapenum
    kerbrute
    nbtscanner
    smbscan
    davtest
    adenum
    proxychains-ng
    hcxtools
    hcxdumptool
    bloodhound
    bloodhound-py
    psudohash
    responder
    maltego
    polenum

    # OSINT tools
    maigret
    sherlock

    # networking
    netcat-openbsd
    whois
    dnsutils
    mtr
    traceroute
  ];
}
