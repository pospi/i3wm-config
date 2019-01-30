# Complete i3wm configuration

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

## systemctl services

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
