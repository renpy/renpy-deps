import platform

if platform.mac_ver()[0] or platform.win32_ver()[0]:
    print "--disable-midi"
else:
    print
    
