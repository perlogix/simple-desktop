# simple-desktop

simple-desktop provides an opinionated, performant, and responsive experience to daily-users and developers on the Ubuntu 20+ desktop.

Our mission is to make Linux laptops the best option for people building the future.

![main screenshot](https://github.com/perlogix/simple-desktop/raw/main/simple-desktop-screenshot.png)

#### Table of Contents

1. [Benefits](#benefits)
2. [Features](#features)
3. [Install](#install)
   - [PreReqs](#prereqs)
   - [Run](#run)
4. [Rollback](#rollback)
5. [Why?](#why)
6. [Known Issues](#known-issues)
7. [Screenshots](#performance---before--after)
8. [Roadmap](#roadmap)
9. [Thank You](#thank-you)
10. [Reporting Bugs](#reporting-bugs)

### Benefits

- Chromebook alternative/grandma friendly
- A great Linux setup for work and gaming laptops
- 5-15% performance and responsiveness increase
- Saves hours of configurations to get a modern desktop

### Features

- **Performance enhancements**

  - Speed-up updates
  - Increase file limits
  - Disable grub timeout
  - Disable powersave on WiFi
  - Remove Desktop auto-starts
  - Optimize ext4 mount options `noatime nodiratime discard commit=120`
  - Configure CloudFlare and Google DNS
  - Disable services including `openvpn fwupd-refresh NetworkManager-wait-online tracker-store`
  - Optimize kernel parameters sysctl.conf
  - Enable tund service only for desktop/VM
  - Enable auto-cpufreq only for laptops
  - Enable grub boot options `quiet transparent_hugepage=madvise nowatchdog`
  - Install custom kernel and newer graphics drivers
  - Optimize block settings `nr_requests,read_ahead_kb,add_random,rq_affinity,iosched/low_latency`
  - Block ads, and fakenews sites - https://github.com/StevenBlack/hosts

- **Install third-party apps** (optional)

  - Zoom
  - Docker
  - Flatpak
  - Spotify
  - Discord
  - Google Chrome
  - Microsoft Teams
  - Citrix Receiver

- **Install developer experience** (optional)

  - Install:

    - git credential helper
    - `jq zsh vim tmate cpulimit fzf`
    - bottom https://github.com/ClementTsang/bottom
    - lsd https://github.com/Peltoche/lsd
    - bat https://github.com/sharkdp/bat
    - lazydocker https://github.com/jesseduffield/lazydocker
    - delta https://github.com/dandavison/delta
    - procs https://github.com/dalance/procs
    - bandwhich https://github.com/imsnif/bandwhich
    - vimrc https://github.com/amix/vimrc
    - oh-my-zsh https://github.com/robbyrussell/oh-my-zsh
    - powerlevel10k https://github.com/romkatv/powerlevel10k
    - oh-my-zsh plugins `fzf git zsh-autosuggestions zsh-syntax-highlighting colored-man-pages`

  - Experience:
    - GNOME terminal padding
    - Use bottom as system monitor
    - Shorter and additional shell aliases

- **Install custom kernel**

  - Liquorix - Gaming/Media (Zen Kernel) https://liquorix.net/

- **Install latest graphics drivers**

  - oibaf/graphics-drivers (PPA)
  - graphics-drivers (PPA)

- **Default installs**

  - `resolvconf curl vim net-tools gnome-tweaks dconf-cli gnome-shell-extensions chrome-gnome-shell gnome-shell-extension-prefs ubuntu-restricted-extras ubuntu-restricted-addons inxi rar unrar tar unzip lzip p7zip-full p7zip-rar dmidecode mokutil libarchive-tools make gettext git`
  - bleachbit - https://www.bleachbit.org/

- **Enhanced user experience**

  - Full dark mode
  - Increased power settings
  - Better Gedit & Terminal defaults
  - Font easier on the eyes - `Liberation Sans`
  - Papirus icon theme https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
  - Vimix Material Design GNOME shell theme https://github.com/vinceliuice/vimix-gtk-themes
  - Extensions
    - User Themes - https://extensions.gnome.org/extension/19/user-themes/
    - Dash-to-Panel https://extensions.gnome.org/extension/1160/dash-to-panel/
    - TopIcon Plus - https://extensions.gnome.org/extension/1031/topicons/
    - GNOME Fuzzy App Search - https://extensions.gnome.org/extension/3956/gnome-fuzzy-app-search/
  - Disable
    - Notifications
    - GPS/Tracking
    - Animations
    - Update Manager/Bug Reporting
    - Recent Files / App Usage
    - Desktop Icons
    - Multiple Workspaces
    - Some Search Providers
  - More keybindings:
    ```sh
    activate-window-menu ['<Alt>space']
    area-screenshot-clip ['<Ctrl><Shift>Print']
    area-screenshot ['<Shift>Print']
    battery-status-static ['XF86Battery']
    begin-move ['<Alt>F7']
    begin-resize ['<Alt>F8']
    calculator-static ['XF86Calculator']
    calculator ['<Super>c']
    close ['<Alt>F4']
    control-center-static ['XF86Tools']
    cycle-group ['<Alt>F6']
    cycle-group-backward ['<Shift><Alt>F6']
    cycle-panels-backward ['<Shift><Control><Alt>Escape']
    cycle-panels ['<Control><Alt>Escape']
    cycle-windows ['<Alt>Escape']
    cycle-windows-backward ['<Shift><Alt>Escape']
    decrease-text-size ['<Primary><Alt>minus']
    eject-static ['XF86Eject']
    email-static ['XF86Mail']
    help ['', '<Super>F1']
    hibernate-static ['XF86Suspend', 'XF86Hibernate']
    home-static ['XF86Explorer']
    home ['<Super>f','<Super>e']
    increase-text-size ['<Primary><Alt>equal']
    keyboard-brightness-down-static ['XF86KbdBrightnessDown']
    keyboard-brightness-toggle-static ['XF86KbdLightOnOff']
    keyboard-brightness-up-static ['XF86KbdBrightnessUp']
    magnifier ['<Alt><Super>8']
    magnifier-zoom-in ['<Alt><Super>equal']
    magnifier-zoom-out ['<Alt><Super>minus']
    maximize ['<Super>Up']
    max-screencast-length uint32 30
    media-static ['XF86AudioMedia']
    mic-mute-static ['XF86AudioMicMute']
    minimize ['<Super>h']
    move-to-monitor-down ['<Super><Shift>Down']
    move-to-monitor-left ['<Super><Shift>Left']
    move-to-monitor-right ['<Super><Shift>Right']
    move-to-monitor-up ['<Super><Shift>Up']
    move-to-workspace-1 ['<Super><Shift>Home']
    move-to-workspace-down ['<Super><Shift>Page_Down', '<Control><Shift><Alt>Down']
    move-to-workspace-last ['<Super><Shift>End']
    move-to-workspace-left ['<Control><Shift><Alt>Left']
    move-to-workspace-right ['<Control><Shift><Alt>Right']
    move-to-workspace-up ['<Super><Shift>Page_Up', '<Control><Shift><Alt>Up']
    next-static ['XF86AudioNext', '<Ctrl>XF86AudioNext']
    panel-main-menu ['<Alt>F1']
    panel-run-dialog ['<Super>r']
    pause-static ['XF86AudioPause']
    playback-forward-static ['XF86AudioForward']
    playback-random-static ['XF86AudioRandomPlay']
    playback-repeat-static ['XF86AudioRepeat']
    playback-rewind-static ['XF86AudioRewind']
    play-static ['XF86AudioPlay', '<Ctrl>XF86AudioPlay']
    power-static ['XF86PowerOff']
    previous-static ['XF86AudioPrev', '<Ctrl>XF86AudioPrev']
    rfkill-bluetooth-static ['XF86Bluetooth']
    rfkill-static ['XF86WLAN', 'XF86UWB', 'XF86RFKill']
    rotate-video-lock-static ['<Super>o']
    screen-brightness-cycle-static ['XF86MonBrightnessCycle']
    screen-brightness-down-static ['XF86MonBrightnessDown']
    screen-brightness-up-static ['XF86MonBrightnessUp']
    screencast ['<Ctrl><Shift><Alt>R']
    screenreader ['<Alt><Super>s']
    screensaver-static ['XF86ScreenSaver']
    screensaver ['<Super>l']
    screenshot-clip ['<Ctrl>Print']
    screenshot ['Print']
    search-static ['XF86Search']
    search ['<Super>s']
    show-desktop ['<Super>d']
    stop-static ['XF86AudioStop']
    suspend-static ['XF86Sleep']
    switch-applications-backward ['<Shift><Super>Tab']
    switch-applications ['<Super>Tab']
    switch-group-backward ['<Shift><Super>Above_Tab', '<Shift><Alt>Above_Tab']
    switch-group ['<Super>Above_Tab', '<Alt>Above_Tab']
    switch-input-source-backward ['<Shift><Super>space', '<Shift>XF86Keyboard']
    switch-input-source ['<Super>space', 'XF86Keyboard']
    switch-panels-backward ['<Shift><Control><Alt>Tab']
    switch-panels ['<Control><Alt>Tab']
    switch-to-workspace-1 ['<Super>Home']
    switch-to-workspace-down ['<Super>Page_Down', '<Control><Alt>Down']
    switch-to-workspace-last ['<Super>End']
    switch-to-workspace-left ['<Control><Alt>Left']
    switch-to-workspace-right ['<Control><Alt>Right']
    switch-to-workspace-up ['<Super>Page_Up', '<Control><Alt>Up']
    switch-windows ['<Alt>Tab']
    switch-windows-backward ['<Shift><Alt>Tab']
    terminal ['<Super>t', '<Primary><Alt>t']
    toggle-maximized ['<Alt>F10']
    touchpad-off-static ['XF86TouchpadOff']
    touchpad-on-static ['XF86TouchpadOn']
    touchpad-toggle-static ['XF86TouchpadToggle', '<Ctrl><Super>XF86TouchpadToggle']
    unmaximize ['<Super>Down', '<Alt>F5']
    volume-down-precise-static ['<Shift>XF86AudioLowerVolume', '<Ctrl><Shift>XF86AudioLowerVolume']
    volume-down-quiet-static ['<Alt>XF86AudioLowerVolume', '<Alt><Ctrl>XF86AudioLowerVolume']
    volume-down-static ['XF86AudioLowerVolume', '<Ctrl>XF86AudioLowerVolume']
    volume-mute-quiet-static ['<Alt>XF86AudioMute']
    volume-mute-static ['XF86AudioMute']
    volume-up-precise-static ['<Shift>XF86AudioRaiseVolume', '<Ctrl><Shift>XF86AudioRaiseVolume']
    volume-up-quiet-static ['<Alt>XF86AudioRaiseVolume', '<Alt><Ctrl>XF86AudioRaiseVolume']
    volume-up-static ['XF86AudioRaiseVolume', '<Ctrl>XF86AudioRaiseVolume']
    window-screenshot ['<Alt>Print']
    window-screenshot-clip ['<Ctrl><Alt>Print']
    www-static ['XF86WWW']
    ```

- **Automatic daily system admin tasks:**

  - Update snaps
  - Update flatpaks
  - Update firmware
  - Update APT packages
  - BleachBit cleanup
  - Remove old snaps
  - Clear Journal logs
  - Remove old kernels
  - Remove rotated logs
  - Filesystem trim for SSDs
  - Package and snap updates
  - Set file security permissions
  - Remove log files older than 30 days
  - Clear contents of log files bigger than 100M

- **Automatic weekly system admin tasks:**

  - Remove trash
  - Remove temp files
  - Remove file history duration

- **Basic security hardening**

  - Restrict cron
  - Lock root account
  - Set files owernships
  - Set files permissions
  - Remove extra users and groups
  - Enable UFW firewall and deny incoming connections

## Install

If it is not a fresh, clean install. **BACKUP ALL DATA** before running simple-desktop!!!!

DO NOT INSTALL ON SERVERS!!!! (See [Roadmap](#roadmap))

### PreReqs

- 8 GB of RAM
- / mounted as ext4
- Internet connection
- **Disable Secure Boot**
- Laptop/Desktop built in the last five years

```sh
wget 'https://raw.githubusercontent.com/perlogix/simple-desktop/main/simple-desktop.sh' && chmod 0755 ./simple-desktop.sh
```

### Run

```sh
sudo -E ./simple-desktop.sh setup && ./simple-desktop.sh install theme && sudo -E ./simple-desktop.sh install developer && sudo ./simple-desktop.sh install developer && sudo ./simple-desktop.sh remove bloat && sudo ./simple-desktop.sh install cleanup_script && sudo reboot
```

## Rollback

```sh
sudo ./simple-desktop.sh rollback
```

## Why?

Why didn't you create your own distro? You never know; let us know here what you think in an issue.

As a mostly remote company, we want to offer our employees the best environment to do their work while saving hardware, tools, and support costs. We work in regulated industries and have to comply with cyber insurance and Government requirements (e.g., ISO, CMMI, CMMC). We believe that the recent cost reductions and advancements in hardware with Linux 5.8+ features make it the perfect time to switch.

#### How Many Linux Users Are There?

_GlobalStats_

- Desktop OS USA = 1.88%
- Desktop OS worldwide = 1.84%

_NetMarketShare_

- Desktop OS Worldwide = 3.2% (Incl. Chrome OS)

_Popular users of Linux_

- IBM
- DoD
- FAA
- NASA
- Google
- Amazon
- Microsoft
- Dreamworks Animation
- Nearly all exchanges (NYSE / LSE)
- US Nuclear Security Administration

#### How Many Linux Developers?

_Stack Overflow 2020 Insights_ - https://insights.stackoverflow.com/survey/2020#technology-platforms

- 26% have Linux as their primary OS.
- 55% prefer Linux platforms. Top of the list.

#### Other Linux Stats

- 29.7% of known servers (web) use Linux.
- 72.56% of mobile/tablet users are Android globally.
- Since 11/2017, 100% of the Top 500 Supercomputers in the world run Linux.
- 7,235 out of 44,121 games on Steam are Linux compatible. (# doubled in 3 years)
- Linux OS Market to rise 19.2% CAGR until 2027- https://www.globenewswire.com/news-release/2020/06/22/2051401/0/en/Linux-OS-Market-to-Rise-at-19-2-CAGR-till-2027-Increasing-Applications-in-the-Gaming-Industry-Will-Bode-Well-for-Market-Growth-says-Fortune-Business-Insights.html

**Why haven't you made the switch yet?**

## Known Issues

- SecureBoot has to be **disabled**, or your computer will not boot after applying simple-desktop
- Sometimes the screen flickers after install, reboot and if it still doesn't fix it, run `/opt/simple-desktop/bin/simple-desktop-maintenance.sh` and reboot
- Android in a Box (anbox) does not currently work on the Liquorix kernel without a kernel rebuild

## Roadmap

- System metrics
- Easy remote help
- Recommendations
- Plugin/plan support
- More third-party apps
- User profiles (developer, server, government)
- Desktop fleet management features

## Thank You

This project wouldn't be a thing without open great source contributors on the Linux Kernel team, Debian/Ubuntu teams, GNOME extensions maintainers, and DevTools makers.

## Reporting Bugs

Please run and submit the generated report:

```sh
sudo simple-desktop.sh system
```

Example report:

```sh
System:    Kernel: 5.11.0-17.1-liquorix-amd64 x86_64 bits: 64 compiler: N/A Desktop: Gnome 3.36.7 
           Distro: Ubuntu 20.04.2 LTS (Focal Fossa) 
Machine:   Type: Laptop System: Micro-Star product: GS66 Stealth 10SFS v: REV:1.0 serial: <filter> 
           Mobo: Micro-Star model: MS-16V1 v: REV:1.0 serial: <filter> UEFI: American Megatrends v: E16V1IMS.112 
           date: 11/19/2020 
Battery:   ID-1: BAT1 charge: 51.6 Wh condition: 59.1/95.0 Wh (62%) model: MSI BIF0_9 status: Charging 
CPU:       Topology: 6-Core model: Intel Core i7-10750H bits: 64 type: MT MCP arch: N/A L2 cache: 12.0 MiB 
           flags: avx avx2 lm nx pae sse sse2 sse3 sse4_1 sse4_2 ssse3 vmx bogomips: 62399 
           Speed: 2601 MHz min/max: 800/2601 MHz Core speeds (MHz): 1: 2601 2: 2602 3: 2601 4: 2467 5: 2601 6: 2292 7: 2600 
           8: 1625 9: 2601 10: 2600 11: 2600 12: 2600 
Graphics:  Device-1: Intel UHD Graphics vendor: Micro-Star MSI driver: i915 v: kernel bus ID: 00:02.0 
           Device-2: NVIDIA vendor: Micro-Star MSI driver: nvidia v: 460.73.01 bus ID: 01:00.0 
           Display: server: X.Org 1.20.9 driver: modesetting,nvidia unloaded: fbdev,nouveau,vesa tty: N/A 
           OpenGL: renderer: Mesa Intel UHD Graphics (CML GT2) 
           v: 4.6 Mesa 21.2.0-devel (git-eb6d990 2021-04-29 focal-oibaf-ppa) direct render: Yes 
Audio:     Device-1: Intel Comet Lake PCH cAVS vendor: Micro-Star MSI driver: snd_hda_intel v: kernel bus ID: 00:1f.3 
           Device-2: NVIDIA TU104 HD Audio vendor: Micro-Star MSI driver: snd_hda_intel v: kernel bus ID: 01:00.1 
           Sound Server: ALSA v: k5.11.0-17.1-liquorix-amd64 
Network:   Device-1: Intel Wi-Fi 6 AX201 driver: iwlwifi v: kernel port: 4000 bus ID: 00:14.3 
           IF: wlo1 state: up mac: <filter> 
           Device-2: Intel driver: igc v: kernel port: 3000 bus ID: 3c:00.0 
           IF: enp60s0 state: down mac: <filter> 
           IF-ID-1: docker0 state: down mac: <filter> 
Drives:    Local Storage: total: 476.94 GiB used: 31.54 GiB (6.6%) 
           ID-1: /dev/nvme0n1 vendor: Samsung model: MZVLB512HAJQ-00000 size: 476.94 GiB 
Partition: ID-1: / size: 64.86 GiB used: 31.51 GiB (48.6%) fs: ext4 dev: /dev/nvme0n1p5 
Sensors:   System Temperatures: cpu: 65.0 C mobo: N/A 
           Fan Speeds (RPM): N/A 
Info:      Processes: 397 Uptime: 27m Memory: 31.18 GiB used: 2.55 GiB (8.2%) Init: systemd runlevel: 5 Compilers: gcc: 9.3.0 
           Shell: simple-desktop. inxi: 3.0.38 
SystemD:   0 loaded units listed.
Dmesg:     
           ACPI BIOS Error (bug): Failure creating named object [\_SB.PCI0.RP17.PXSX.TBDU], AE_ALREADY_EXISTS (20201113/dswload2-326)
           ACPI Error: AE_ALREADY_EXISTS, During name lookup/catalog (20201113/psobject-220)
           Initramfs unpacking failed: Decoding failed
           igc 0000:3c:00.0: no suspend buffer for PTM
Journal:     
           May 01 23:06:04 skeeter gdm-password][2292]: gkr-pam: unable to locate daemon control file
SecureBoot:   
           SecureBoot disabled

```
