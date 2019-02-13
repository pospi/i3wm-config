# Complete i3wm configuration

<!-- MarkdownTOC -->

- [Features](#features)
- [Setup](#setup)
    - [systemctl services](#systemctl-services)
- [License](#license)

<!-- /MarkdownTOC -->

## Features

- Noteworthy key bindings:
    - Volume controls with audible feedback
    - Media keys via [playerctl](https://github.com/acrisci/playerctl)
    - Layout and boot app workspaces with a single keypress *(see "(C)ommunications" in config)*
    - Move windows left/right between workspaces and follow them to their destination
- Window tabbing, program runner & command execution via [rofi](https://github.com/DaveDavenport/rofi)
- Starts relevant utility apps (eg. Gnome calculator) in floating mode
- Fancy lock screen (pixellated desktop with overlay)
- Automatic suspend:
    - Does not trigger when apps are fullscreen, which takes care of most video playback situations
    - Does not trigger when music or other media is playing (detection implemented via PulseAudio)
- Automatic monitor profile configuration via `autorandr` (mod+F7 binding as final resort)
- Management of screen backlight via hotkeys or tray icon
- Script hooks for rebinding Xinput device buttons & keys when inserted
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
    sudo apt install -y i3 rofi sox cpufrequtils xterm autorandr xautolock indicator-brightness

    # other dependencies
    pip install i3ipc
    wget https://github.com/acrisci/playerctl/releases/download/v2.0.1/playerctl-2.0.1_amd64.deb
    sudo dpkg -i playerctl-2.0.1_amd64.deb

You also need to put an image at `~/Pictures/lockscreen.png`, which will be overlaid at the bottom centre of your screen when the PC is locked.

### systemctl services

It's far easier to wire everything into `systemctl` than it is to try to drive things the other way around. You will need these service files installed into `/etc/systemd/system/`. Replace `/home/pospi` with the path to your own homedir.

`auto-monitorconf.service`:

    [Unit]
    Description=Autoconfigure monitor inputs
    After=suspend.target

    [Service]
    User=pospi
    Type=oneshot
    Environment=DISPLAY=:0
    ExecStart=/home/pospi/.config/i3/auto-monitorconf.sh resume

    [Install]
    WantedBy=suspend.target

`i3lock-suspend.service`:

    [Unit]
    Description=i3lock on suspend
    Before=sleep.target

    [Service]
    User=pospi
    Type=forking
    Environment=DISPLAY=:0
    ExecStart=/home/pospi/.config/i3/i3lock.sh suspend

    [Install]
    WantedBy=sleep.target


`i3lock-resume.service`:

    [Unit]
    Description=i3lock on resume
    After=suspend.target

    [Service]
    User=pospi
    Type=forking
    Environment=DISPLAY=:0
    ExecStart=/home/pospi/.config/i3/i3lock.sh resume

    [Install]
    WantedBy=suspend.target

Now that those are set up, enable them:

    sudo systemctl enable auto-monitorconf
    sudo systemctl enable i3lock-suspend
    sudo systemctl enable i3lock-resume

## License

WTFPL
