# Complete i3wm configuration

<!-- MarkdownTOC -->

- [Features](#features)
- [Setup](#setup)
- [License](#license)

<!-- /MarkdownTOC -->

## Features

- Noteworthy key bindings:
    - Volume controls with audible feedback
    - Media keys via [playerctl](https://github.com/acrisci/playerctl)
    - Layout and boot app workspaces with a single keypress *(see "(C)ommunications" in config)*
    - Move windows left/right between workspaces and follow them to their destination
- Window tabbing, program runner & command execution via [rofi](https://github.com/DaveDavenport/rofi)
- [Compton](https://wiki.archlinux.org/index.php/Compton) for window compositing, to allow WebGL & overlay apps like [Peek](https://github.com/phw/peek) to work
- Starts relevant utility apps (eg. Gnome calculator) in floating mode
- Fancy lock screen (pixellated workspace with overlay)
- Automatic lock & suspend:
    - Does not trigger when apps are fullscreen, which takes care of most video playback situations
    - Does not trigger when music or other media is playing (detection implemented via PulseAudio)
- Battery status / low battery warnings
- Automatic monitor profile configuration via `autorandr` (mod+F7 binding as final resort)
- Management of screen backlight via hotkeys or tray icon
- Script hooks for rebinding Xinput device buttons & keys when inserted
- Desktop background assignment via [Nitrogen](https://wiki.archlinux.org/index.php/Nitrogen)
- Tray items:
    - CPU performance mode
    - VPN connection status
    - Standard i3status battery level, network connection info, date / time & app icons
- Background processes: *(see end of `config`)*
    - Ubuntu network manager tray UI
    - [EncFS folder manager](https://moritzmolch.com/apps/mencfsm/index.html)
    - [MEGA](https://mega.nz) file sync
    - [Redshift](http://jonls.dk/redshift/) colour temperature manager

## Setup
    
    # find a tempdir
    cd ~/Downloads
    
    # get i3 apt keys
    wget http://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2018.01.30_all.deb
    sudo dpkg -i ./sur5r-keyring_2018.01.30_all.deb
    echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list

    # apt keys for other dependencies
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y ppa:indicator-brightness/ppa

    # install main packages
    sudo apt update
    sudo apt install -y i3 rofi sox cpufrequtils xterm xautolock compton nitrogen indicator-brightness xbacklight arandr blueman pavucontrol acpi
    sudo pip install autorandr i3ipc

    # other dependencies
    wget https://github.com/acrisci/playerctl/releases/download/v2.0.1/playerctl-2.0.1_amd64.deb
    sudo dpkg -i playerctl-2.0.1_amd64.deb

    # integrate with systemd
    mkdir -p $HOME/.config/systemd/user
    systemctl --user enable $HOME/.config/i3/systemd/battery-check.service

    sed "s/pospi/$USER/" $HOME/.config/i3/systemd/auto-monitorconf.service | sudo tee /etc/systemd/system/auto-monitorconf.service
    sed "s/pospi/$USER/" $HOME/.config/i3/systemd/i3lock-suspend.service | sudo tee /etc/systemd/system/i3lock-suspend.service
    sed "s/pospi/$USER/" $HOME/.config/i3/systemd/i3lock-resume.service | sudo tee /etc/systemd/system/i3lock-resume.service

    sudo systemctl enable auto-monitorconf.service
    sudo systemctl enable i3lock-suspend.service
    sudo systemctl enable i3lock-resume.service

    systemctl --user daemon-reload
    systemctl --user start $HOME/.config/i3/systemd/battery-check.service
    sudo systemctl daemon-reload

You also need to put an image at `~/Pictures/lockscreen.png`, which will be overlaid at the bottom centre of your screen when the PC is locked; and another at `~/Pictures/wallpaper.png` for the background. Alternatively you can disable these features or edit to point to your own paths.


## License

WTFPL
