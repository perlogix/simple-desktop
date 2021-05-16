#!/bin/bash
#
# simple-desktop
# Opinionated, performant, and responsive experience to daily-users and developers on the Ubuntu 20+ desktop
#
# Copyright (C) 2021  Perlogix, Timothy Marcinowski
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

PRIM_DISK=$(df -h / | grep dev | awk '{ print $1 }')
SETUP_LOG="/opt/simple-desktop/logs/setup.log"
SETUP_ERR_LOG="/opt/simple-desktop/logs/setup_err.log"

is_root() {
  if [[ $(whoami) != "root" ]]; then
    echo "run again with:  sudo -E $0"
    exit 1
  fi
}

# Create GitHub issue submission
system_info() {
  command -v inxi 1>/dev/null && inxi -Fxz || echo "Install inxi:  sudo apt install -y inxi"
  echo -e "\033[1mSystemD:  \033[0m $(systemctl --failed --no-pager | grep -v UNIT)"
  echo -e "\033[1mDmesg:    \033[0m \n$(dmesg -tP --level=err,emerg,crit,alert | sed 's/^/           /')"
  echo -e "\033[1mJournal:    \033[0m \n$(journalctl -p "emerg..err" --no-pager -b | grep -v 'kernel\|Logs\|ssh' | sed 's/^/           /')"
  echo -e "\033[1mSecureBoot:  \033[0m \n$(mokutil --sb-state 2>/dev/null | sed 's/^/           /')"
  if [[ -f /opt/simple-desktop/logs/setup.log ]]; then
    echo -e "\033[1mSetupErrors:    \033[0m \n$(sed 's/^/           /' /opt/simple-desktop/logs/setup_err.log)"
  fi
  if [[ -f /opt/simple-desktop/.first_run ]]; then
    echo -e "\033[1mFirstRun:    \033[0m \n$(sed 's/^/           /' /opt/simple-desktop/.first_run)"
  fi
}

# Update components
update() {
  case $1 in
    hosts)
      wget -c 'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews/hosts'
      sed -i "s/localhost$/localhost $(hostname)/g" hosts
      mv -f hosts /etc/
      ;;
    *)
      echo "options: slack,discord,chrome,firefox,spotify,zoom,teams,overclock,developer,theme,docker,flatpak,cleanup_script,disable_spectre"
      ;;
  esac
}

# Install common desktop apps
install() {
  case $1 in
    slack)
      snap install slack --classic
      ;;

    chrome)
      wget -c 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
      apt install -y ./google-chrome-stable_current_amd64.deb
      rm -f ./google-chrome-stable_current_amd64.deb
      ;;

    spotify)
      snap install spotify
      ;;

    zoom)
      wget -c 'https://zoom.us/client/latest/zoom_amd64.deb'
      apt install -y ./zoom_amd64.deb
      rm -f ./zoom_amd64.deb
      ;;

    teams)
      curl -L 'https://packages.microsoft.com/keys/microsoft.asc' | sudo apt-key add -
      echo 'deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main' >/etc/apt/sources.list.d/teams.list
      apt update
      apt install -y teams
      ;;

    discord)
      snap install discord
      ;;

    firefox)
      apt install firefox
      ;;

    overclock)
      echo 'arm_freq=1900' >>/boot/firmware/config.txt
      echo 'over_voltage=4' >>/boot/firmware/config.txt
      ;;

    docker)
      curl -sSL https://get.docker.com/ | sh
      ;;

    theme)
      setup_theme
      ;;

    cleanup_script)
      setup_cleanup_script
      ;;

    disable_spectre)
      setup_disable_spectre
      ;;

    flatpak)
      apt update
      apt install -y flatpak gnome-software-plugin-flatpak
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      ;;

    anbox)
      # This does not work yet with zen-kernel 5.8
      apt update
      apt install -y android-tools-adb wget curl lzip tar unzip squashfs-tools
      snap install --devmode --beta anbox
      wget -c https://github.com/geeks-r-us/anbox-playstore-installer/raw/master/install-playstore.sh
      chmod -f 0755 ./install-playstore.sh
      ./install-playstore.sh
      /snap/anbox/current/bin/anbox-bridge.sh start
      rm -rf ./install-playstore.sh ./anbox-work
      ;;

    developer)
      apt install -y jq zsh make git vim libsecret-1-0 libsecret-1-dev libglib2.0-dev libnss3-tools tmate cpulimit fzf

      ZSH="$(command -v zsh || grep zsh /etc/shells | tail -n 1)"
      sed -i "s|/bin/bash|$ZSH|g" /etc/passwd

      # Create temp install directory
      TEMPDIR="$HOME/.tmp98713245"
      mkdir -p "$TEMPDIR"
      cd "$TEMPDIR" || echo "Cannot make temp directory" >&2

      # Install a better top/htop
      wget -c https://github.com/ClementTsang/bottom/releases/latest/download/bottom_x86_64-unknown-linux-gnu.tar.gz
      tar -zxvf bottom_x86_64-unknown-linux-gnu.tar.gz
      cp -f ./btm /usr/bin/

      # Install a better ls
      wget -c https://github.com/Peltoche/lsd/releases/download/0.20.1/lsd-0.20.1-x86_64-unknown-linux-gnu.tar.gz
      tar -zxvf lsd-0.20.1-x86_64-unknown-linux-gnu.tar.gz
      cp -f ./lsd-*-x86_64-unknown-linux-gnu/lsd /usr/bin/

      # Install a colorful cat
      wget -c https://github.com/sharkdp/bat/releases/download/v0.18.0/bat-v0.18.0-x86_64-unknown-linux-gnu.tar.gz
      tar -zxvf bat-v0.18.0-x86_64-unknown-linux-gnu.tar.gz
      cp -f ./bat-v0.18.0-x86_64-unknown-linux-gnu/bat /usr/bin/

      # Install lazydocker
      wget -c https://github.com/jesseduffield/lazydocker/releases/download/v0.12/lazydocker_0.12_Linux_x86_64.tar.gz
      tar -zxvf ./lazydocker_0.12_Linux_x86_64.tar.gz
      chmod -f 0755 ./lazydocker
      cp -f ./lazydocker /usr/bin/

      # Install a better colorful diff
      wget -c https://github.com/dandavison/delta/releases/download/0.7.1/delta-0.7.1-x86_64-unknown-linux-gnu.tar.gz
      tar -zxvf ./delta-0.7.1-x86_64-unknown-linux-gnu.tar.gz
      cp -f ./delta-0.7.1-x86_64-unknown-linux-gnu/delta /usr/bin/

      # Install procs a colorful ps
      wget -c https://github.com/dalance/procs/releases/download/v0.11.4/procs-v0.11.4-x86_64-lnx.zip
      unzip procs-v0.11.4-x86_64-lnx.zip
      cp -f ./procs /usr/bin/

      # Install network utilization CLI bandwich
      wget -c https://github.com/imsnif/bandwhich/releases/download/0.20.0/bandwhich-v0.20.0-x86_64-unknown-linux-musl.tar.gz
      tar -zxvf ./bandwhich-v0.20.0-x86_64-unknown-linux-musl.tar.gz
      cp -f ./bandwhich /usr/bin/

      # Install git credential helper
      make --directory=/usr/share/doc/git/contrib/credential/libsecret
      git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret

      # Install better vim defaults
      git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
      sh ~/.vim_runtime/install_awesome_vimrc.sh

      # Install oh-my-zsh
      git clone --depth=1 git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
      chsh -s "$ZSH" && "$ZSH" -i -c "omz update"

      # Install powerlevel10k and oh-my-zsh plugins
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME"/.oh-my-zsh/custom/themes/powerlevel10k
      git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME"/.oh-my-zsh/custom/plugins/zsh-autosuggestions
      git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME"/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

      rm -rf "$TEMPDIR"

      # Create a better system monitor desktop icon
      cat <<'EOF' >/usr/share/applications/sysmonitor.desktop
[Desktop Entry]
Version=1.0
Name=System Monitor
Type=Application
Comment=View System Performance
Terminal=true
Exec=btm -g --hide_time --hide_table_gap
Icon=org.gnome.SystemMonitor
Categories=ConsoleOnly;System;Monitor;Task;
GenericName=Process Viewer
Keywords=Monitor;System;Process;CPU;Memory;Network;History;Usage;Performance;Task;Manager;Activity;Performance;
EOF

      # Install a better default zsh PS1
      cp "$HOME"/.zshrc /opt/simple-desktop/backup_confs/
      cat <<'EOF' >"$HOME"/.zshrc
export ZSH=$HOME/.oh-my-zsh

function prompt_my_cpu_temp() {
  if [[ ! -f /sys/class/thermal/thermal_zone0/temp ]]; then
    return
  fi
  integer cpu_temp="$(</sys/class/thermal/thermal_zone0/temp) / 1000"
  if ((cpu_temp >= 80)); then
    p10k segment -s HOT -f red -t "${cpu_temp}"$'\uE339' -i $'\uF737'
  elif ((cpu_temp >= 60)); then
    p10k segment -s WARM -f yellow -t "${cpu_temp}"$'\uE339' -i $'\uE350'
  else
    p10k segment -s COLD -f green -t "${cpu_temp}"$'\uE339' -i $'\uE350'
  fi
}

function batppf() {
  bat -ppf "$1"
}

function audit() {
  echo -e "\033[1mSystemD:  \033[0m $(sudo systemctl --failed --no-pager | grep -v UNIT)"
  echo -e "\033[1mDmesg:    \033[0m \n$(sudo dmesg -tP --level=err,emerg,crit,alert | sed 's/^/           /')"
  echo -e "\033[1mJournal:    \033[0m \n$(sudo journalctl -p "emerg..err" --no-pager -b | grep -v 'kernel\|Logs\|ssh'| sed 's/^/           /')"
  echo -e "\033[1mSecureBoot:  \033[0m \n$(mokutil --sb-state 2>/dev/null | sed 's/^/           /')"
  echo -e "\033[1mVulnerabilities:  \033[0m \n$(grep -r . /sys/devices/system/cpu/vulnerabilities/ 2>/dev/null | sed 's/^/           /')"
}

function keybindings() {
  {
    gsettings list-recursively org.gnome.settings-daemon.plugins.media-keys &
    gsettings list-recursively org.gnome.desktop.wm.keybindings
  } | awk '{sub($1 FS, "")}7' | sort
}

function extract () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)     echo "'$1' cannot be extracted via extract()" ;;
      esac
  else
    echo "'$1' is not a valid file"
  fi
}

ZSH_THEME="powerlevel10k/powerlevel10k"
POWERLEVEL9K_MODE=nerdfont-complete
POWERLEVEL9K_SHORTEN_STRATEGY=truncate_beginning
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
POWERLEVEL9K_DISABLE_GITSTATUS=true
POWERLEVEL9K_TIME_FORMAT='%D{%I:%M}'
POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL='\uE0B2'
POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL='\uE0B0'
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%F{blue}╭─'
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{blue}╰%f '
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(command_execution_time my_cpu_temp ram load disk_usage)

plugins=(
  fzf
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  colored-man-pages
)

source "$ZSH"/oh-my-zsh.sh

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias apt-get='sudo apt-get'
alias apt='sudo apt'
alias audit=audit
alias bat=batppf
alias c='clear'
alias cpr='rsync -ah --info=progress2'
alias crons='sudo find /var/spool/cron /etc/crontab /etc/anacrontab -type f -exec cat {} \; 2>/dev/null | grep -v "^#\|^[A-Z]"| sed -e "s/[[:space:]]\+/ /g" | awk NF'
alias df="df -hT"
alias diff="delta -s"
alias docker='sudo docker'
alias docker-compose='sudo docker-compose'
alias dpkg='sudo dpkg'
alias du='du -h'
alias egrep='egrep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.vscode,node_modules,vendor,.clangd,__pycache__,.npm,.cache,.composer}'
alias extract=extract
alias ff='find . -name'
alias flightoff='sudo rfkill unblock all'
alias flighton='sudo rfkill block all'
alias fgrep='fgrep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.vscode,node_modules,vendor,.clangd,__pycache__,.npm,.cache,.composer}'
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.vscode,node_modules,vendor,.clangd,__pycache__,.npm,.cache,.composer}'
alias halt='sudo /sbin/halt'
alias h='history'
alias ls='lsd'
alias l='lsd -l'
alias la='lsd -a'
alias lla='lsd -la'
alias lt='lsd --tree'
alias ll='lsd -lh'
alias lsa='lsd -lah'
alias climit='cpulimit -l $((20 * $(nproc --all))) -b -z -q -e'
alias mkdir='mkdir -p'
alias mute='amixer set Master mute'
alias netfiles='sudo lsof -i 4 2>/dev/null'
alias netstat='sudo netstat -tulanp'
alias netreset='sudo systemd-resolve --flush-caches && sudo nmcli networking off && sudo nmcli networking on'
alias open='xdg-open'
alias old='lsd -lt  | tail -n 10'
alias journalctl='sudo journalctl'
alias json='python3 -m json.tool'
alias keybindings=keybindings
alias more='less'
alias new='lsd -ltr  | tail -n 10'
alias path='echo $PATH | tr -s ":" "\n"'
alias poweroff='sudo sync && systemctl poweroff'
alias pkill='sudo pkill -9 -f'
alias pubip='dig @1.1.1.1 ch txt whoami.cloudflare +short | cut -d\" -f 2'
alias reboot='sudo sync && sudo systemctl reboot'
alias restart='sudo systemctl --no-ask-password try-restart'
alias serve='python3 -m http.server'
alias service='sudo service'
alias services='sudo systemctl list-unit-files --no-legend --type=service --state=enabled --no-pager'
alias shutdown='sudo sync && systemctl poweroff'
alias scp='scp -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no"'
alias snap='sudo snap'
alias ssh='ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no"'
alias systemctl='sudo systemctl'
alias tb='nc termbin.com 9999'
alias top='btm -g --hide_time --hide_table_gap'
alias topcpu='sudo ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head'
alias topfiles='find . -type f -exec du -Sh {} + | sort -rh | head'
alias topmem='sudo ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head'
alias topof='sudo lsof 2>/dev/null | cut -d" " -f1 | sort | uniq -c | sort -r -n | head'
alias timers='sudo systemctl list-timers --all --no-pager'
alias tree='lsd --tree'
alias root='sudo su -'
alias unmute='amixer set Master unmute && amixer set Headphone unmute'
alias vrm='vagrant box list | cut -f 1 -d " " | xargs -L 1 vagrant box remove -f'
alias vi='vim'
alias wflow='watch -n1 "sudo lsof -i TCP:80,443"'
alias q='exit'
alias quit='exit'

export VISUAL=vim
export EDITOR=$VISUAL
export PAGER=less
export HISTSIZE=3000
export HISTCONTROL=ignoredups:erasedups
export GIT_PAGER="delta -s"
export FZF_COMPLETION_TRIGGER='**'
export BAT_THEME="Sublime Snazzy"

export __GL_SHADER_DISK_CACHE_PATH=$HOME/.cache
export __GL_SHADER_DISK_CACHE=1
export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1

bindkey -s "^[OM" "^M" 2>/dev/null
EOF
      chown -Rf "$SUDO_USER":"$SUDO_USER" "$HOME"
      ;;

    *)
      echo "options: slack,discord,chrome,firefox,spotify,zoom,teams,overclock,developer,theme,docker,flatpak,cleanup_script,disable_spectre"
      ;;

  esac
}

# Remove common desktop apps
remove() {
  case $1 in
    slack)
      snap remove slack
      ;;

    chrome)
      apt remove -y "google-chrome*"
      ;;

    spotify)
      snap remove spotify
      ;;

    zoom)
      apt remove -y "zoom*"
      ;;

    teams)
      apt remove -y teams
      ;;

    discord)
      snap remove discord
      ;;

    firefox)
      apt remove -y firefox
      ;;

    bloat)
      apt remove -y thunderbird transmission-common cheese aisleriot gnome-mahjongg gnome-mines gnome-sudoku remmina
      ;;

    theme)
      dconf load / </opt/simple-desktop/backup_confs/dconf-settings.ini
      ;;

    *)
      echo "slack,discord,chrome,firefox,spotify,zoom,teams,bloat,theme"
      ;;

  esac
}

# Check if backup is present, if not delete current file
restore_delete() {
  if [[ -f "$2" ]]; then
    cp -f "$2" "$1"
  else
    rm -f "$1"
  fi
}

# Detect internet connection
detect_internet() {
  if [[ $(ping -c 1 1.1.1.1 | grep '100% packet loss') != "" ]]; then
    echo "Internet seems to be down"
    exit 1
  fi
}

# rollback does it's best to reset the OS back to it's original state
rollback() {
  cp -f /opt/simple-desktop/backup_confs/default-wifi-powersave-on.conf /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf
  cp -f /opt/simple-desktop/backup_confs/hosts /etc/hosts
  restore_delete /opt/simple-desktop/backup_confs/99-limits.conf /etc/security/limits.d/99-limits.conf
  restore_delete /opt/simple-desktop/backup_confs/99-sysctl.conf /etc/sysctl.d/99-sysctl.conf
  cp -f /opt/simple-desktop/backup_confs/fstab /etc/fstab
  restore_delete /opt/simple-desktop/backup_confs/rc.local /etc/rc.local
  add-apt-repository --remove ppa:oibaf/graphics-drivers -y
  add-apt-repository --remove ppa:damentz/liquorix -y
  add-apt-repository --remove ppa:papirus/papirus -y
  add-apt-repository --remove ppa:graphics-drivers/ppa -y
  systemctl enable openvpn
  systemctl enable sssd
  systemctl enable NetworkManager-wait-online
  systemctl enable motd-news.timer
  systemctl enable fstrim.timer
  systemctl enable irqbalance
  systemctl enable apt-daily.service
  systemctl enable apt-daily.timer
  systemctl enable apt-daily-upgrade.timer
  systemctl enable apt-daily-upgrade.service
  systemctl enable fwupd-refresh.timer
  systemctl disable simple-desktop-maintenance.timer
  ufw logging on
  ufw disable
  gnome-extensions disable 'dash-to-panel@jderose9.github.com'
  dconf load / </opt/simple-desktop/backup_confs/dconf-settings.ini
  busctl --user call "org.gnome.Shell" "/org/gnome/Shell" "org.gnome.Shell" "Eval" "s" 'Meta.restart("Restarting…")'
  snap remove --purge auto-cpufreq
  apt remove -y tuned linux-image-liquorix-amd64 linux-headers-liquorix-amd64 papirus-icon-theme vim gnome-tweaks dconf-cli gnome-shell-extensions chrome-gnome-shell gnome-shell-extension-prefs bleachbit ubuntu-restricted-extras ubuntu-restricted-addons inxi dmidecode mokutil make gettext git
  cp -f /opt/simple-desktop/backup_confs/grub /etc/default/grub
  update-grub
}

# Setup cleanup systemd timers jobs for system maintenance
setup_cleanup_script() {

  # Install update and cleanup script
  cat <<'EOF' >/opt/simple-desktop/bin/simple-desktop-maintenance.sh
#!/bin/bash

# Sync time
if [ "$(systemctl status systemd-timesyncd.service | grep 'Active: active')" != "" ]; then
    systemctl restart systemd-timesyncd.service
fi

# Clean unused Docker resources
if [ "$(command -v docker)" ]; then
    # Update ecs-agent if present
    if [ "$(docker ps | grep amazon/amazon-ecs-agent)" != "" ]; then
        docker pull amazon/amazon-ecs-agent:latest
    fi
    docker system prune -a -f
fi

# Update flatpaks
command -v flatpak && flatpak update -y -v

# Update PI firmware
command -v rpi-eeprom-config && rpi-eeprom-config -a

# Update firmware
if [ "$(command -v fwupdmgr)" ]; then
    fwupdmgr refresh --force
    fwupdmgr update -y
fi

if [ "$(command -v swupd)" ]; then
    # Update Clear Linux
    swupd update -y

    # Repair Clear Linux
    swupd repair -y -x

    # Clean Clear Linux Updates
    swupd clean -y
fi

if [ "$(command -v dpkg)" ]; then
  # Fix or clean any lock files
  rm -f /var/lib/dpkg/updates/*

  # Remove all linux kernels except the current one
  dpkg --list | awk '{ print $2 }' | grep -e 'linux-\(headers\|image\)-.*[0-9]\($\|-generic\)' | grep -v "$(uname -r | sed 's/-generic//')" | xargs apt purge -y

  # Remove old Linux source
  dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt purge -y
fi

if [ "$(command -v apt)" ]; then
  # Fix or clean any lock files
  rm -f /var/lib/apt/lists/lock
  rm -f /var/cache/apt/archives/lock

  # Upgrade packages
  apt update -y
  ACCEPT_EULA=Y DEBIAN_FRONTEND=noninteractive apt upgrade -y

  # Clean garbage
  apt autoremove -y --purge
  apt -y autoclean
  apt -y clean
fi

if [ "$(command -v yum)" ]; then
  yum update -y
  yum clean all
  rm -rf /var/cache/yum
fi

# Upgrade and remove old snaps
if [ "$(command -v snap)" ]; then
  snap set system refresh.retain=2
  snap refresh
  snap list --all | awk '/disabled/{print $1, $3}' | while read -r snapname revision; do snap remove "$snapname" --revision="$revision"; done
fi

# Clean journal
if [ "$(command -v journalctl)" ]; then
  journalctl --rotate
  journalctl --vacuum-files=2
  journalctl --vacuum-size=100M
fi

# BleachBit Cleaner
if [ "$(command -v bleachbit)" ]; then
  bleachbit --clean adobe_reader.cache \
    adobe_reader.mru \
    adobe_reader.tmp \
    apt.autoclean \
    apt.autoremove \
    apt.clean \
    apt.package_lists \
    deepscan.backup \
    deepscan.ds_store \
    deepscan.thumbs_db \
    deepscan.tmp \
    deepscan.vim_swap_root \
    deepscan.vim_swap_user \
    evolution.cache \
    firefox.crash_reports \
    flash.cache \
    flash.cookies \
    gedit.recent_documents \
    gimp.tmp \
    gnome.run \
    gnome.search_history \
    java.cache \
    journald.clean \
    libreoffice.cache \
    libreoffice.history \
    nautilus.history \
    openofficeorg.cache \
    openofficeorg.recent_documents \
    screenlets.logs \
    skype.chat_logs \
    skype.installers \
    slack.cache \
    sqlite3.history \
    system.cache \
    system.localizations \
    system.recent_documents \
    system.rotated_logs \
    system.tmp \
    system.trash \
    thumbnails.cache \
    x11.debug_logs \
    zoom.cache \
    zoom.logs

  # BleachBit for all users
  grep home /etc/passwd | grep -v 'nologin\|false' | awk -F':' '{ print $ 1 }' | while IFS= read -r user; do
    runuser -l "$user" -c "bleachbit --clean adobe_reader.cache \
  adobe_reader.mru \
  adobe_reader.tmp \
  apt.autoclean \
  apt.autoremove \
  apt.clean \
  apt.package_lists \
  deepscan.backup \
  deepscan.ds_store \
  deepscan.thumbs_db \
  deepscan.tmp \
  deepscan.vim_swap_root \
  deepscan.vim_swap_user \
  evolution.cache \
  firefox.crash_reports \
  flash.cache \
  flash.cookies \
  gedit.recent_documents \
  gimp.tmp \
  gnome.run \
  gnome.search_history \
  java.cache \
  journald.clean \
  libreoffice.cache \
  libreoffice.history \
  nautilus.history \
  openofficeorg.cache \
  openofficeorg.recent_documents \
  screenlets.logs \
  skype.chat_logs \
  skype.installers \
  slack.cache \
  sqlite3.history \
  system.cache \
  system.localizations \
  system.recent_documents \
  system.rotated_logs \
  system.tmp \
  system.trash \
  thumbnails.cache \
  x11.debug_logs \
  zoom.cache \
  zoom.logs"
  done
fi

# Clean hidden temp and cache files
for n in $(find / -type d \( -name ".tmp" -o -name ".temp" -o -name ".cache" \) 2>/dev/null); do find "$n" -type f -delete; done

# Clean old logs
find /var/log -name '*.log' -type f -mtime +30 -delete
find /var/log -name '*.gz' -type f -delete
find /var/log -name '*.log.[0-9$]' -type f -delete

# Clear contents of log files bigger than 100M
for log in $(find / -type f -size +100M 2>/dev/null | grep '\.log$\|\.log.old$\|\.log.bk$\|\.log.backup$'); do
  echo >"$log"
done

# Set 0600 to SSH files
for n in $(find / -type d -name ".ssh" 2>/dev/null); do find "$n" -type f -exec chmod -f 0600 {} +; done

# Set files and dirs without user to root
find / -nouser -exec chown -f root {} \; 2>/dev/null

# Set files and dirs without group to root
find / -nogroup -exec chown -f :root {} \; 2>/dev/null

# Remove other world writable permissions on all files
find / -xdev -perm +o=w ! \( -type d -perm +o=t \) ! -type l -ok chmod -v o-w {} \; 2>/dev/null

# Set home directories to 0750 permissions
find /home -maxdepth 1 -mindepth 1 -type d -exec chmod -f 0700 {} \;

# Remove group and other permissions on log files
chmod -Rf g-wx,o-rwx /var/log/*

# Trim SSD
command -v fstrim && fstrim -v /
EOF

  chmod -f 0755 /opt/simple-desktop/bin/simple-desktop-maintenance.sh

  cat <<'EOF' >/etc/systemd/system/simple-desktop-maintenance.service
[Unit]
Description=Run simple-desktop Update & Clean Up Script
After=network.target

[Service]
ExecStart=/opt/simple-desktop/bin/simple-desktop-maintenance.sh
StandardOutput=file:/var/log/simple-desktop-maintenance.log
StandardError=file:/var/log/simple-desktop-maintenance.log

[Install]
WantedBy=default.target
EOF

  cat <<'EOF' >/etc/systemd/system/simple-desktop-maintenance.timer
[Unit]
Description=simple-desktop Update & Clean Up Timer

[Timer]
OnBootSec=30min
Persistent=true

[Install]
WantedBy=timers.target
EOF

  systemctl daemon-reload
  systemctl enable --now simple-desktop-maintenance.timer
}

# Setup /etc/rc.local startup script
setup_rclocal() {
  # Better define the systemd rc-local service
  cat <<'EOF' >/etc/systemd/system/rc-local.service
[Unit]
 Description=/etc/rc.local Compatibility
 ConditionPathExists=/etc/rc.local

[Service]
 Type=forking
 ExecStart=/etc/rc.local
 TimeoutSec=0
 StandardOutput=tty
 RemainAfterExit=yes
 SysVStartPriority=99

[Install]
 WantedBy=multi-user.target
EOF

  # Create rc.local file that sets disk queue thresholds on-boot
  cp -f /etc/rc.local /opt/simple-desktop/backup_confs/
  cat <<'EOF' >/etc/rc.local
#!/bin/sh
for d in /sys/block/[m,s,n,x]*; do
  printf 1024 > "$d"/queue/nr_requests
  printf 1024 > "$d"/queue/read_ahead_kb
  printf 1 > "$d"/queue/add_random
  printf 2 > "$d"/queue/rq_affinity
  printf 1 > "$d"/queue/iosched/low_latency
done
command -v tuned-adm && tuned-adm auto_profile
exit 0
EOF

  chmod -f 0755 /etc/rc.local

  systemctl daemon-reload
  systemctl enable rc-local
}

# Setup mount points in /etc/fstab
setup_fstab() {
  # Disable no access time on files and dirs. Increase commit to disk from 5
  cp -f /etc/fstab /opt/simple-desktop/backup_confs/
  if [[ $(mount | grep ext4 | grep ' / ') != "" ]]; then
    sed -i 's| / .*| /  ext4  rw,noatime,nodiratime,discard,commit=120,errors=remount-ro  0  1|g' /etc/fstab
  fi
  sed -i '/\/boot/ s/defaults.*/defaults,noatime,nodiratime,nosuid,nodev  0  2/g' /etc/fstab
}

# Setup additional kernel parameters
setup_sysctl() {
  # TODO: Set different values based on RAM size
  cp -f /etc/sysctl.d/99-sysctl.conf /opt/simple-desktop/backup_confs/
  cat <<'EOF' >/etc/sysctl.d/99-sysctl.conf
fs.aio-max-nr=1048576
fs.epoll.max_user_watches=12616437
fs.file-max=9223372036854775807
fs.file-nr=736 0 9223372036854775807
fs.inotify.max_queued_events=524288
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=524288
fs.nr_open=1073741816
fs.suid_dumpable=0
kernel.core_pattern=/bin/false
kernel.dmesg_restrict=1
kernel.panic=5
kernel.pid_max=65536
kernel.printk=3 3 3 3
net.core.default_qdisc=fq
net.core.netdev_max_backlog=4096
net.core.rmem_max=16777216
net.core.somaxconn=65535
net.core.wmem_max=16777216
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.all.secure_redirects=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.default.secure_redirects=0
net.ipv4.conf.default.send_redirects=0
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_early_retrans=1
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_max_syn_backlog=8096
net.ipv4.tcp_max_tw_buckets=1440000
net.ipv4.tcp_moderate_rcvbuf=1
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_rmem=4096 12582912 16777216
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_timestamps=0
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_wmem=4096 12582912 16777216
net.ipv6.conf.all.accept_redirects=0
net.ipv6.conf.default.accept_redirects=0
vm.dirty_background_ratio=5
vm.dirty_expire_centisecs=12000
vm.dirty_ratio=50
vm.dirty_writeback_centisecs=1500
vm.extfrag_threshold=100
vm.max_map_count=262144
vm.min_free_kbytes=80000
vm.mmap_min_addr=65536
vm.swappiness=10
vm.vfs_cache_pressure=50
EOF

  sysctl -p /etc/sysctl.d/99-sysctl.conf
}

# Increase security file limits to max values
setup_limits() {
  cp -f /etc/security/limits.d/99-limits.conf /opt/simple-desktop/backup_confs/ 2>/dev/null
  cat <<'EOF' >/etc/security/limits.d/99-limits.conf
* soft nofile 999999
* hard nofile 999999
root soft nofile 999999
root hard nofile 999999

* soft stack unlimited
* hard stack unlimited
root soft stack unlimited
root hard stack unlimited
EOF
}

# Setup additional grub parameters
setup_grub() {
  cp -f /etc/default/grub /opt/simple-desktop/backup_confs/
  sed -i 's|GRUB_TIMEOUT=.*|GRUB_TIMEOUT=0|g' /etc/default/grub
  sed -i 's|GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT="quiet transparent_hugepage=madvise nowatchdog"|g' /etc/default/grub
  update-grub
}

# Disable Spectre Mitigations
setup_disable_spectre() {
  if [ ! -f "/opt/simple-desktop/backup_confs/grub" ]; then
    cp -f /etc/default/grub /opt/simple-desktop/backup_confs/
  fi
  sed -i 's|GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT="quiet transparent_hugepage=madvise mitigations=off nowatchdog"|g' /etc/default/grub
  update-grub
}

# Setup various networking configurations
setup_network() {
  # Block ads / trackers
  cp -f /etc/hosts /opt/simple-desktop/backup_confs/
  wget -c 'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews/hosts'
  sed -i "s/localhost$/localhost $(hostname)/g" hosts
  mv -f hosts /etc/

  # Turn off powersave on WiFi settings
  cp -f /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf /opt/simple-desktop/backup_confs/
  sed -i 's|wifi.powersave.*|wifi.powersave = 2|g' /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf
}

# Setup advanced Gnome configurations including Tweaks
setup_theme() {
  # Install MesloLGS Nerd font
  mkdir -p "$HOME"/.local/share/fonts
  cd "$HOME"/.local/share/fonts || echo "Cannot install MesloLGS fonts" >&2
  wget -c https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
  wget -c https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
  wget -c https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
  wget -c https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf

  # Install Desktop background
  sudo curl -L https://raw.githubusercontent.com/perlogix/simple-desktop/main/simple-desktop-background.png -o /usr/share/backgrounds/simple-desktop-default.png

  # Install Vimix Material Design GNOME shell theme
  curl -L https://github.com/vinceliuice/vimix-gtk-themes/archive/master.zip -o vimix.zip
  unzip vimix.zip
  ./vimix-gtk-themes-master/install.sh
  rm -rf vimix*

  # Install Dock-to-Panel
  git clone https://github.com/home-sweet-gnome/dash-to-panel.git
  cd dash-to-panel || echo "Cannot install Dock-to-Panel" >&2
  make install
  gnome-extensions enable 'dash-to-panel@jderose9.github.com'
  cd .. && rm -rf dash-to-panel

  # Install TopIcons-plus
  git clone https://github.com/phocean/TopIcons-plus.git
  cd TopIcons-plus || echo "Cannot install TopIcons-plus" >&2
  make install
  cd .. && rm -rf TopIcons-plus

  # Install gnome-fuzzy-app-search
  git clone https://gitlab.com/Czarlie/gnome-fuzzy-app-search.git
  cd gnome-fuzzy-app-search || echo "Cannot install gnome-fuzzy-app-search" >&2
  make install
  cd .. && rm -rf gnome-fuzzy-app-search

  busctl --user call "org.gnome.Shell" "/org/gnome/Shell" "org.gnome.Shell" "Eval" "s" 'Meta.restart("Restarting…")'

  # Install Gnome Desktop UI settings
  cat <<'EOF' >./dconf-settings.ini
[apps/update-manager]
first-run=false
launch-count=1
launch-time=int64 1598240380

[ca/desrt/dconf-editor]
saved-pathbar-path='favorit'
saved-view='/'
show-warning=false
window-height=500
window-is-maximized=true
window-width=540

[com/ubuntu/sound]
allow-amplified-volume=true

[com/ubuntu/touch/network]
gps=false

[com/ubuntu/update-notifier]
no-show-notifications=true
release-check-time=uint32 1598240370
show-apport-crashes=false
show-livepatch-status-icon=false

[desktop/ibus/general]
preload-engines=['xkb:us::eng']
version='1.5.22'

[org/gnome/control-center]
last-panel='display'

[org/gnome/desktop/app-folders]
folder-children=['Utilities', 'YaST']

[org/gnome/desktop/app-folders/folders/Utilities]
apps=['gnome-abrt.desktop', 'gnome-system-log.desktop', 'gnome-system-monitor.desktop', 'gucharmap.desktop', 'nm-connection-editor.desktop', 'org.gnome.baobab.desktop', 'org.gnome.Calculator.desktop', 'org.gnome.DejaDup.desktop', 'org.gnome.Dictionary.desktop', 'org.gnome.DiskUtility.desktop', 'org.gnome.eog.desktop', 'org.gnome.Evince.desktop', 'org.gnome.FileRoller.desktop', 'org.gnome.fonts.desktop', 'org.gnome.Screenshot.desktop', 'org.gnome.seahorse.Application.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Usage.desktop', 'simple-scan.desktop', 'vinagre.desktop', 'yelp.desktop']
categories=['X-GNOME-Utilities']
name='X-GNOME-Utilities.directory'
translate=true

[org/gnome/desktop/app-folders/folders/YaST]
categories=['X-SuSE-YaST']
name='suse-yast.directory'
translate=true

[org/gnome/desktop/background]
color-shading-type='solid'
picture-options='zoom'
picture-uri='file:///usr/share/backgrounds/simple-desktop-background.png'
primary-color='#000000'
secondary-color='#000000'
show-desktop-icons=false

[org/gnome/desktop/input-sources]
sources=[('xkb', 'us')]
xkb-options=@as []

[org/gnome/desktop/interface]
clock-show-weekday=true
cursor-theme='whiteglass'
document-font-name='Liberation Sans 12'
enable-animations=false
font-name='Liberation Sans 12'
gtk-im-module='gtk-im-context-simple'
gtk-theme='vimix-dark-laptop-doder'
icon-theme='Papirus-Dark'
menus-have-icons=true
monospace-font-name='Liberation Mono 12'
show-battery-percentage=true
toolkit-accessibility=false

[org/gnome/desktop/notifications]
application-children=['update-manager']
show-banners=false
show-in-lock-screen=false

[org/gnome/desktop/notifications/application/apport-gtk]
application-id='apport-gtk.desktop'
enable-sound-alerts=false

[org/gnome/desktop/notifications/application/snap-store-ubuntu-software]
application-id='snap-store_ubuntu-software.desktop'
enable-sound-alerts=false

[org/gnome/desktop/notifications/application/update-manager]
application-id='update-manager.desktop'
enable=false
enable-sound-alerts=false
show-banners=false
show-in-lock-screen=false

[org/gnome/desktop/peripherals/mouse]
accel-profile='default'

[org/gnome/desktop/peripherals/touchpad]
speed=1.0
two-finger-scrolling-enabled=true

[org/gnome/desktop/privacy]
disable-microphone=false
old-files-age=uint32 7
recent-files-max-age=7
remember-app-usage=false
remember-recent-files=false
remove-old-temp-files=true
remove-old-trash-files=true
report-technical-problems=false

[org/gnome/desktop/screensaver]
color-shading-type='solid'
picture-options='zoom'
picture-uri='file:///usr/share/backgrounds/simple-desktop-background.png'
primary-color='#000000'
secondary-color='#000000'

[org/gnome/desktop/search-providers]
disabled=['org.gnome.Terminal.desktop', 'org.gnome.seahorse.Application.desktop', 'org.gnome.Characters.desktop', 'org.gnome.Software.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Calculator.desktop']
sort-order=['org.gnome.Contacts.desktop', 'org.gnome.Documents.desktop', 'org.gnome.Nautilus.desktop']

[org/gnome/desktop/sound]
allow-volume-above-100-percent=true

[org/gnome/desktop/wm/preferences]
auto-raise=true
num-workspaces=1
titlebar-font='Liberation Sans Bold 12'

[org/gnome/desktop/wm/keybindings]
show-desktop=['<Super>d']
panel-run-dialog=['<Super>r']

[org/gnome/evince/default]
window-ratio=(0.98039215686274506, 0.75757575757575757)

[org/gnome/evolution-data-server]
migrated=true
network-monitor-gio-name=''

[org/gnome/file-roller/general]
compression-level='maximum'

[org/gnome/file-roller/listing]
list-mode='as-folder'
name-column-width=250
show-path=false
sort-method='name'
sort-type='ascending'

[org/gnome/file-roller/ui]
sidebar-width=200
window-height=480
window-width=600

[org/gnome/gedit/plugins]
active-plugins=['spell', 'docinfo', 'modelines', 'time']

[org/gnome/gedit/plugins/filebrowser]
root='file:///'
tree-view=true
virtual-root='file:///'

[org/gnome/gedit/preferences/editor]
auto-save=true
background-pattern='none'
create-backup-copy=true
display-line-numbers=true
editor-font='Liberation Mono 16'
highlight-current-line=false
scheme='cobalt'
tabs-size=uint32 2
use-default-font=false
wrap-last-split-mode='word'
wrap-mode='none'

[org/gnome/gedit/preferences/ui]
bottom-panel-visible=false
show-tabs-mode='auto'
side-panel-visible=false
statusbar-visible=true

[org/gnome/logs]
ignore-warning=true

[org/gnome/mutter]
dynamic-workspaces=false

[org/gnome/nautilus/list-view]
default-column-order=['name', 'size', 'type', 'owner', 'group', 'permissions', 'where', 'date_modified', 'date_modified_with_time', 'date_accessed', 'recency', 'starred', 'detailed_type']
default-visible-columns=['name', 'size', 'type', 'date_modified']
default-zoom-level='standard'

[org/gnome/nautilus/preferences]
default-folder-viewer='icon-view'
recursive-search='local-only'
search-filter-time-type='last_modified'
search-view='icon-view'
show-delete-permanently=true
show-directory-item-counts='always'
show-image-thumbnails='always'
thumbnail-limit=uint64 16

[org/gnome/nautilus/icon-view]
default-zoom-level='large'

[org/gnome/nautilus/window-state]
initial-size=(890, 550)
maximized=true

[org/gnome/nm-applet/eap/0c5c1a01-a52c-4b02-8592-a2e3c1b5a5de]
ignore-ca-cert=false
ignore-phase2-ca-cert=false

[org/gnome/settings-daemon/plugins/color]
night-light-enabled=false

[org/gnome/settings-daemon/plugins/power]
idle-dim=false
sleep-inactive-ac-timeout=3600
sleep-inactive-ac-type='nothing'
sleep-inactive-battery-timeout=3600
sleep-inactive-battery-type='nothing'

[org/gnome/settings-daemon/plugins/xsettings]
antialiasing='rgba'
hinting='slight'

[org.gnome.settings-daemon.plugins.power]
sleep-inactive-ac-type='nothing'
sleep-inactive-battery-type='nothing'

[org/freedesktop/tracker/miner/files]
crawling-interval=-2
enable-monitors=false

[org/gnome/settings-daemon/plugins/print-notifications]
active=false

[org/gnome/settings-daemon/plugins/media-keys]
calculator=['<Super>c']
decrease-text-size=['<Primary><Alt>minus']
home=['<Super>f','<Super>e']
increase-text-size=['<Primary><Alt>equal']
logout=@as []
search=['<Super>s']
terminal=['<Super>t','<Primary><Alt>t']

[org/gnome/shell]
app-picker-view=uint32 1
disabled-extensions=['desktop-icons@csoriano']
enabled-extensions=['user-theme@gnome-shell-extensions.gcampax.github.com', 'dash-to-panel@jderose9.github.com', 'TopIcons@phocean.net', 'gnome-fuzzy-app-search@gnome-shell-extensions.Czarlie.gitlab.com']
favorite-apps=['org.gnome.Nautilus.desktop', 'snap-store_ubuntu-software.desktop', 'gnome-control-center.desktop']

[org/gnome/gnome-session]
logout-prompt=true

[org/gnome/shell/app-switcher]
current-workspace-only=true

[org/gnome/shell/extensions/caffeine]
show-notifications=false
user-enabled=true

[org/gnome/shell/extensions/dash-to-dock]
animate-show-apps=false
apply-custom-theme=true
dash-max-icon-size=35
dock-position='BOTTOM'
extend-height=false
force-straight-corner=true
preferred-monitor=0
click-action='minimize'
multi-monitor=false
unity-backlit-items=true

[org/gnome/shell/extensions/dash-to-panel]
animate-app-switch=false
animate-window-launch=false
available-monitors=[0]
check-update=true
dot-style-unfocused='DASHES'
force-check-update=true
group-apps=true
hotkeys-overlay-combo='TEMPORARILY'
isolate-monitors=false
leftbox-padding=-1
multi-monitors=false
panel-element-positions='{"0":[{"element":"showAppsButton","visible":true,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":false,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":false,"position":"stackedBR"}],"1":[{"element":"showAppsButton","visible":true,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":false,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":false,"position":"stackedBR"}]}'
scroll-panel-action='CYCLE_WINDOWS'
secondarymenu-contains-showdetails=true
show-appmenu=false
show-running-apps=true
show-window-previews=false
status-icon-padding=8
stockgs-keep-dash=false
stockgs-keep-top-panel=false
stockgs-panelbtn-click-only=false
taskbar-locked=true
trans-bg-color='#041a3b'
trans-gradient-bottom-opacity=0.0
trans-gradient-top-opacity=0.20000000000000001
trans-panel-opacity=0.90000000000000002
trans-use-custom-bg=true
trans-use-custom-gradient=true
trans-use-custom-opacity=true
tray-padding=0
tray-size=16

[org/gnome/shell/extensions/desktop-icons]
show-home=false
show-trash=false

[org/gnome/shell/extensions/freon]
hot-sensors=['__average__']
update-time=10

[org/gnome/shell/extensions/topicons]
icon-size=20
icon-spacing=12
tray-order=1
tray-pos='center'

[org/gnome/shell/extensions/user-theme]
name='vimix-dark-laptop-doder'

[org/gnome/shell/window-switcher]
current-workspace-only=true

[org/gnome/software]
download-updates=false

[org/gnome/system/location]
enabled=false

[org/gnome/terminal/legacy]
new-tab-position='next'
theme-variant='dark'

[org/gnome/terminal/legacy/profiles:]
default='6c44a062-abad-4850-913f-4b040bb49284'
list=['6c44a062-abad-4850-913f-4b040bb49284']

[org/gnome/terminal/legacy/profiles:/:6c44a062-abad-4850-913f-4b040bb49284]
audible-bell=false
background-transparency-percent=20
bold-is-bright=true
default-size-columns=150
default-size-rows=32
allow-bold=true
background-color='#04041A1A3B3B'
bold-color='#f2f2f2f2f2f2'
bold-color-same-as-fg=true
font='MesloLGS NF 16'
foreground-color='#f2f2f2f2f2f2'
highlight-background-color='#'
highlight-colors-set=true
highlight-foreground-color='#'
palette=['#303030303030', '#e1e132321a1a', '#6a6ab0b01717', '#ffffc0c00505', '#72729F9FCFCF', '#ecec00004848', '#2a2aa7a7e7e7', '#f2f2f2f2f2f2', '#5d5d5d5d5d5d', '#ffff36361e1e', '#7b7bc9c91f1f', '#ffffd0d00a0a', '#00007171ffff', '#ffff1d1d6262', '#4b4bb8b8fdfd', '#a0a02020f0f0']
use-system-font=false
use-theme-background=false
use-theme-colors=false
use-theme-transparency=false
use-transparent-background=true

[org/gtk/settings/color-chooser]
custom-colors=[(0.56486666666666685, 0.72156491228070196, 0.7400000000000001, 1.0), (0.51372549019607838, 0.58039215686274515, 0.58823529411764708, 1.0)]
selected-color=(true, 0.56486666666666685, 0.72156491228070196, 0.7400000000000001, 1.0)

[org/gtk/settings/file-chooser]
date-format='regular'
location-mode='path-bar'
show-hidden=false
show-size-column=true
show-type-column=true
sidebar-width=161
sort-column='name'
sort-directories-first=true
sort-order='ascending'
type-format='category'
window-position=(66, 80)
window-size=(1231, 902)
EOF

  dconf dump / >/opt/simple-desktop/backup_confs/dconf-settings.ini
  dconf load / <./dconf-settings.ini
  rm -f ./dconf-settings.ini
}

# Setup various baseline OS configurations
setup_base() {
  touch /opt/simple-desktop/.first_run
  echo -e "sha1sum: $(sha1sum "$0")\nstart_time: $(date -u +'%Y-%m-%dT%H:%M:%SZ')\ninstall_user: $SUDO_USER" >>/opt/simple-desktop/.first_run

  # Setup apt-get / upgrades
  sed -i 's|Prompt=.*|Prompt=never|g' /etc/update-manager/release-upgrades
  sed -i 's/APT::Periodic::Unattended-Upgrade.*/APT::Periodic::Unattended-Upgrade "0";/' /etc/apt/apt.conf.d/20auto-upgrades
  echo 'APT::Acquire::Queue-Mode "access";' >/etc/apt/apt.conf.d/99parallel
  echo 'APT::Acquire::Retries 3;' >>/etc/apt/apt.conf.d/99parallel
  echo 'Acquire::Languages "none";' >>/etc/apt/apt.conf.d/00aptitude

  # Add enhanced drivers, custom kernel and icon pack
  add-apt-repository ppa:damentz/liquorix -y
  add-apt-repository ppa:papirus/papirus -y

  if [[ $(systemd-detect-virt 2>/dev/null) == "none" ]]; then
    add-apt-repository ppa:oibaf/graphics-drivers -y
    if [[ $(lspci 2>/dev/null | grep NVIDIA) != "" ]]; then
      add-apt-repository ppa:graphics-drivers/ppa -y
    fi
  fi

  # Update apt cache
  apt update

  # Install all the things
  ACCEPT_EULA=Y DEBIAN_FRONTEND=noninteractive apt install -y linux-image-liquorix-amd64 linux-headers-liquorix-amd64 papirus-icon-theme resolvconf curl vim net-tools gnome-tweaks dconf-cli gnome-shell-extensions chrome-gnome-shell gnome-shell-extension-prefs bleachbit ubuntu-restricted-extras ubuntu-restricted-addons inxi rar unrar tar unzip lzip p7zip-full p7zip-rar dmidecode mokutil libarchive-tools make gettext git

  # Remove bug / error reporting services
  apt remove -y whoopsie apport apport-gtk ubuntu-report unattended-upgrades kerneloops plymouth

  # Auto install drivers
  ubuntu-drivers install

  # Disable uneeded services
  systemctl disable openvpn
  systemctl disable NetworkManager-wait-online
  systemctl disable motd-news.timer
  systemctl disable fstrim.timer
  systemctl disable irqbalance
  systemctl disable apt-daily.service
  systemctl disable apt-daily.timer
  systemctl disable apt-daily-upgrade.timer
  systemctl disable apt-daily-upgrade.service
  systemctl disable fwupd-refresh.timer
  systemctl --user mask tracker-extract
  systemctl --user mask tracker-miner-fs
  systemctl --user mask tracker-store

  # Enable new services
  systemctl enable resolvconf

  # Install auto-cpufreq or tuned based on device type
  if [[ -f "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" ]]; then
    if [[ "$(dmidecode --string chassis-type 2>/dev/null | grep 'Notebook\|Hand Held\|Laptop\|Portable\|Sub Notebook')" != "" ]]; then
      snap install auto-cpufreq
      auto-cpufreq --install
      systemctl enable irqbalance
      # Disable Intel TCO watchdog timers
      echo "blacklist iTCO_wdt" >>/etc/modprobe.d/blacklist.conf
    fi
  fi

  if [[ $(snap list 2>/dev/null | grep auto-cpufreq) == "" ]]; then
    apt install -y tuned
    systemctl enable tuned
    tuned-adm auto_profile
  fi

  # Install Entrust Root Cert
  wget -c 'https://entrust.com/root-certificates/entrust_g2_ca.cer'
  cp entrust_g2_ca.cer /usr/share/ca-certificates/mozilla/entrust_g2_ca.crt
  ln -sf /usr/share/ca-certificates/mozilla/entrust_g2_ca.crt /etc/ssl/certs/entrust_g2_ca.crt
  update-ca-certificates
  rm -f entrust_g2_ca.cer

  # FSCK every 10 boots
  tune2fs -c 10 "$PRIM_DISK"

  # Remove Desktop auto starts and icons
  rm -f /etc/xdg/autostart/{update-notifier.desktop,tracker*.desktop,ubuntu-report*.desktop,orca*.desktop,*DejaDup.Monitor.desktop,gnome-welcome-tour.desktop}
  rm -f "$HOME"/.config/autostart/{update-notifier.desktop,tracker*.desktop,ubuntu-report*.desktop,orca*.desktop,*DejaDup.Monitor.desktop,gnome-welcome-tour.desktop}
  sed -i 's/NoDisplay=true/NoDisplay=false/g' /etc/xdg/autostart/*.desktop
  rm -f /usr/share/applications/{software-properties-livepatch.desktop,bleachbit-root.desktop,org.gnome.Software.desktop,vim.desktop,usb-creator-gtk.desktop,htop.desktop,gnome-system-monitor.desktop,org.bleachbit.BleachBit.desktop}

  # Overriding default DNS with CloudFlare & Google DNS Services
  cp -f /etc/resolvconf/resolv.conf.d/head /opt/simple-desktop/backup_confs/
  cat <<'EOF' >/etc/resolvconf/resolv.conf.d/head
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF
}

setup_security() {

  for users in games gnats irc list news sync uucp; do
    userdel -r "$users" 2>/dev/null
  done

  command -v grpck && yes | grpck

  find /boot/ -type f -name '*.cfg' -exec chmod -f 0400 {} \; 2>/dev/null

  find / -nouser -exec chown -f root {} \; 2>/dev/null

  find / -nogroup -exec chown -f :root {} \; 2>/dev/null

  find / -xdev -perm +o=w ! \( -type d -perm +o=t \) ! -type l -ok chmod -v o-w {} \; 2>/dev/null

  find /home -maxdepth 1 -mindepth 1 -type d -exec chmod -f 0700 {} \;

  chmod -Rf g-wx,o-rwx /var/log/*

  chmod -f 0750 /etc/sudoers.d
  chmod -f 0440 /etc/sudoers.d/*

  echo 'root' >/etc/cron.allow
  echo 'root' >/etc/at.allow

  chmod -f 0700 /etc/cron.{d,daily,hourly,monthly,weekly}
  chmod -f 0700 /etc/cron.*/*
  chmod -f 0755 /var/spool/cron/crontabs
  chmod -f 0600 /var/spool/anacron/cron.*
  chmod -f 0600 /var/spool/at/*
  chmod -f 0600 /var/spool/cron/crontabs/*
  chmod -f 0400 /etc/crontab
  chmod -f 0400 /etc/cron.allow
  chmod -f 0400 /etc/at.allow

  chown -f root:root /etc/ssh/sshd_config
  chmod -f og-rwx /etc/ssh/sshd_config

  chmod -f 0640 /etc/login.defs

  chown -f root:root /etc/passwd
  chmod -f 0644 /etc/passwd

  chown -f root:shadow /etc/shadow
  chmod -f o-rwx,g-wx /etc/shadow

  chown -f root:root /etc/group
  chmod -f 0644 /etc/group

  chown -f root:shadow /etc/gshadow
  chmod -f o-rwx,g-rw /etc/gshadow

  chown -f root:root /etc/passwd-
  chmod -f 0600 /etc/passwd-

  chown -f root:root /etc/shadow-
  chmod -f 0600 /etc/shadow-

  chown -f root:root /etc/group-
  chmod -f 0600 /etc/group-

  chown -f root:root /etc/gshadow-
  chmod -f 0600 /etc/gshadow-

  chown -Rf root:root /var/cache/private

  chmod -f 700 /boot /etc/{iptables,arptables}

  chown -f root:root /etc/modprobe.d/*.conf
  chmod -f 0644 /etc/modprobe.d/*.conf

  chown -f root:root /etc/grub.conf
  chown -Rf root:root /etc/grub.d
  chmod -f og-rwx /etc/grub.conf
  chmod -Rf og-rwx /etc/grub.d

  chmod -f 0640 /etc/cups/cupsd.conf

  passwd -l root

  # Deny all incoming traffic and turn off firewall logging
  ufw default deny incoming
  ufw logging off
  ufw enable

  # Rotate daily and keep only one backup
  sed -i 's/rotate [0-9]/rotate 1/g' /etc/logrotate.d/*
  sed -i 's/weekly\|monthly/daily/g' /etc/logrotate.d/*
  sed -i 's/rotate [0-9]/rotate 1/g' /etc/logrotate.conf
  sed -i 's/weekly\|monthly/daily/g' /etc/logrotate.conf
  sed -i 's/#SystemMaxFiles=100/SystemMaxFiles=7/g' /etc/systemd/journald.conf

  # Disable CrashShell and DumpCore in SystemD
  sed -i 's/^#DumpCore=.*/DumpCore=no/' /etc/systemd/system.conf
  sed -i 's/^#CrashShell=.*/CrashShell=no/' /etc/systemd/system.conf
}

setup_simple_desktop() {
  # Create simple-desktop directories
  mkdir -p /opt/simple-desktop/{bin,backup_confs,extras,logs}
  chown -Rf "$SUDO_USER":root /opt/simple-desktop
}

# CLI arguments
case "$1" in
  setup)
    is_root
    detect_internet
    setup_simple_desktop
    touch $SETUP_LOG $SETUP_ERR_LOG
    setup_base 1>>$SETUP_LOG 2>>$SETUP_ERR_LOG
    setup_network 1>>$SETUP_LOG 2>>$SETUP_ERR_LOG
    setup_fstab 1>>$SETUP_LOG 2>>$SETUP_ERR_LOG
    setup_rclocal 1>>$SETUP_LOG 2>>$SETUP_ERR_LOG
    setup_sysctl 1>>$SETUP_LOG 2>>$SETUP_ERR_LOG
    setup_limits 1>>$SETUP_LOG 2>>$SETUP_ERR_LOG
    setup_grub 1>>$SETUP_LOG 2>>$SETUP_ERR_LOG
    setup_security 1>>$SETUP_LOG 2>>$SETUP_ERR_LOG
    chown -Rf "$SUDO_USER":root /opt/simple-desktop
    chmod -f 0600 /opt/simple-desktop/backup_confs/*
    chmod -f 0600 /opt/simple-desktop/logs/*
    echo "Reboot after all $0 commands are applied"
    echo "end_time: $(date -u +'%Y-%m-%dT%H:%M:%SZ')" >>/opt/simple-desktop/.first_run
    exit 0
    ;;

  install)
    if [[ "$2" != "theme" ]]; then
      is_root
    fi
    detect_internet
    install "$2"
    exit 0
    ;;

  remove)
    is_root
    remove "$2"
    exit 0
    ;;

  cleanup)
    is_root
    /bin/bash /opt/simple-desktop/bin/simple-desktop-maintenance.sh
    exit 0
    ;;

  update)
    is_root
    detect_internet
    update "$2"
    exit 0
    ;;

  system)
    is_root
    system_info
    exit 0
    ;;

  rollback)
    is_root
    detect_internet
    rollback
    exit 0
    ;;

  docs)
    detect_internet
    xdg-open https://github.com/perlogix/simple-desktop
    exit 0
    ;;

  *)
    echo -e "\e[40;38;5;82m $0 \e[0m usage:

  docs     - Open GitHub documentation in a web browser: https://github.com/perlogix/simple-desktop
             example: \e[40;38;5;82m $0 docs \e[0m

  system   - Display friendly system information for reporting purposes
             example: \e[40;38;5;82m sudo -E $0 system \e[0m

  setup    - Automatically sets up Ubuntu 20.x Desktop with a range of opinionated improvements
             example: \e[40;38;5;82m sudo -E $0 setup \e[0m

  install  - Installs commonly used packages
             example: \e[40;38;5;82m sudo -E $0 install \e[0m # Returns list of available packages
             example: \e[40;38;5;82m sudo -E $0 install zoom \e[0m

  remove   - Removes supported packages in this script
             example: \e[40;38;5;82m sudo -E $0 remove \e[0m # Returns list of available packages
             example: \e[40;38;5;82m sudo -E $0 remove zoom \e[0m

  cleanup  - Runs Ubuntu updates and Bleachbit cleaners
             example: \e[40;38;5;82m sudo $0 cleanup \e[0m

  update   - Updates configurations managed by $0
             example: \e[40;38;5;82m sudo -E $0 update \e[0m

  rollback - Revert $0 changes back to default OS configurations and UI settings

  Recommended install: \e[40;38;5;82m sudo -E $0 setup && $0 install theme && sudo -E $0 install developer && sudo $0 install developer && sudo $0 remove bloat && sudo $0 install cleanup_script && sudo reboot \e[0m"
    ;;

esac
