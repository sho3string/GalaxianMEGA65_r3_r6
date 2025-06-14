Galaxian for MEGA65
===================

Galaxian is a pioneering fixed shooter released in 1979 by Namco, with Midway handling its North American distribution. Designed as Namco’s answer to Space Invaders, the game introduced true RGB color graphics and animated multi-color sprites, setting a new standard for arcade visuals. Players control the Galaxip starfighter, tasked with defending Earth from waves of alien invaders that dive-bomb toward the player while firing projectiles. Unlike its predecessor, Space Invaders, enemies in Galaxian attack in dynamic formations, adding an extra layer of challenge. The game’s success led to several sequels, most notably Galaga, which became an arcade legend in its own right.


This core is based on the
[Arcade-Galaxian_MiSTer](https://github.com/MiSTer-devel/Arcade-Galaxian_MiSTer)
Galaxian itself is based on the wonderful work of [alanswx, sorgelig](AUTHORS) and many others.

The core uses the [MiSTer2MEGA65](https://github.com/sy2002/MiSTer2MEGA65)
framework and [QNICE-FPGA](https://github.com/sy2002/QNICE-FPGA) for
FAT32 support (loading ROMs, mounting disks) and for the
on-screen-menu.

How to install on your MEGA65
-----------------------------
Download the powershell or shell script from the **CORE** directory depending on your preferred platform ( Windows, Linux/Unix and MacOS supported )

Run the script: a) First extract all the files within the zip to any working folder.

b) Copy the powershell or shell script to the same folder and execute it to create the following files.

**Ensure the following files are present and sizes are correct**  
![image](https://github.com/user-attachments/assets/84f876f6-5737-4ab7-9cc9-601070eb7828)

For Windows run the script via PowerShell - galaxian_rom_installer.ps1  
Simply select the script and with the right mouse button select the Run with Powershell.

For Linux/Unix/MacOS execute ./mpatrol_rom_installer.sh  
The script will automatically create the /arcade/galaxian folder where the generated ROMs will reside.  

Copy or move "arcade/galaxian" to your MEGA65 SD card: You may either use the bottom SD card tray of the MEGA65 or the tray at the backside of the computer (the latter has precedence over the first).  
