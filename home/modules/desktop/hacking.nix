{pkgs, ...}: {
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
    theharvester
    exploitdb
    arp-scan
    testssl
    thc-hydra
    whatweb
    evil-winrm
    wpscan

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
