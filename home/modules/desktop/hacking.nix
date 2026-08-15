{pkgs, ...}: {
  home.packages = with pkgs; [
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

    maigret
    sherlock

    netcat-openbsd
    whois
    dnsutils
    mtr
    traceroute
  ];
}
