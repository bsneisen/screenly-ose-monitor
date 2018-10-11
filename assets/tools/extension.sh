#!/bin/bash
# Created by didiatworkz
header() {
clear
cat << "EOF"
                            _
   ____                    | |
  / __ \__      _____  _ __| | __ ____
 / / _` \ \ /\ / / _ \| '__| |/ /|_  /
| | (_| |\ V  V / (_) | |  |   <  / /
 \ \__,_| \_/\_/ \___/|_|  |_|\_\/___|
  \____/                www.atworkz.de

EOF
echo
echo "Screenly OSE Monitor extension"
echo
echo
}

header
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "The installation can may be take a while.."
echo
echo
echo

echo "Check packages"
sleep 2
dpkg -s imagemagick &> /dev/null
if [ $? -ne 0 ]; then
    apt update && sudo apt-get install x11-apps imagemagick -y
fi

header
echo "Prepair Screenly Player..."
sleep 2
wget https://raw.githubusercontent.com/didiatworkz/screenly-ose-monitor/master/assets/img/loading.jpg -P /home/pi/

cat >/home/pi/screenshot.sh <<EOF
#!/bin/bash
cp /home/pi/loading.png /home/pi/screenly/static/img/screenshot.png
sleep 60;
while true; do
   DISPLAY=:0 XAUTHORITY=/var/run/lightdm/root/$DISPLAY xwd -root > /tmp/screenshot.xwd
   convert /tmp/screenshot.xwd /home/pi/screenly/static/img/screenshot.png
   sleep 10;
done
exit
EOF

chmod +x /home/pi/screenshot.sh
chown pi:pi /home/pi/screenshot.sh
( crontab -l ; echo "@reboot sleep 20 && /home/pi/screenshot.sh >> /home/pi/screenshot.log 2>1" ) | crontab -
echo "true" > /home/pi/screenly/static/monitor.txt

if [ "$1" != "installer" ]
then
    header
    echo "Screenly OSE Monitor extension successfuly installed"
    echo "Device is being restarted in 5 seconds!"
    sleep 5
    reboot now
fi
exit