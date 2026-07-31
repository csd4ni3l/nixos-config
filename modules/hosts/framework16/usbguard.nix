{self, ...}: {
  flake.nixosModules.Framework16USBGuard = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [usbguard-notifier];

    services.usbguard.rules = ''
      allow id 1d6b:0002                                               # Linux USB 2.0 root hubs
      allow id 1d6b:0003                                               # Linux USB 3.x root hubs
      allow id 046d:c08b serial "205933F25943"                         # Logitech G502 HERO
      allow id 05e3:0610                                               # Internal Framework USB 2.0 hubs
      allow id 05e3:0625                                               # Internal Framework USB 3.x hub
      allow id 0e8d:e616 serial "000000000"                            # MediaTek Bluetooth
      allow id 32ac:0002 serial "11AD1D009612330C15270B00"             # Framework HDMI Expansion Card
      allow id 27c6:609c serial "UID250B1CD7_XXXX_MOC_B0"              # Goodix fingerprint reader
      allow id 32ac:0018 serial "FRAKDKEN0100000000"                   # Framework Laptop 16 keyboard module (ISO)
      allow id 18a5:0422 serial "WN6L17737000"                         # Portable SSD
      allow id 32ac:0005 serial "071C587D208A2D32"                     # Framework 250 GB Storage Expansion Card
      allow id 0bda:8156 serial "4013000001"                           # Framework 2.5 GbE Ethernet Expansion Card
      allow id 1050:0402                                               # Yubico Security Keys
      allow id 090c:2000 serial "CCYYMMDDHHmmSSRMT223"                 # ADATA 32GB pendrive 1
      allow id 090c:2000 serial "CCYYMMDDHHmmSSKAUUER"                 # ADATA 32GB pendrive 2
      allow id 090c:2000 serial "CCYYMMDDHHmmSS14RYN3"                 # ADATA 32GB pendrive 3
      allow id 0951:1666 serial "E0D55E625B4E18C198B30120"             # Kingston DataTraveler 3.0 128GB
      allow id 125f:dc1a serial "2122607280070066"                     # ADATA UV150 16GB pendrive
      allow id 0951:1666 serial "E0D55E6C711617503942000C"             # Kingston DataTraveler 3.0 64GB
      allow id 058f:6387 serial "CDCD1C5C"                             # Unknown Pendrive 2GB
      allow id 3654:4a55 serial "433130323031302E"                     # Headphones
    '';
  };
}
