#!/bin/sh

if command -v pkg >/dev/null 2>&1; then
    echo "Termux"
    pkg update -y
    pkg install -y wget

elif command -v apk >/dev/null 2>&1; then
    echo "iSH"

    apk add wget

else
    echo "Loi script"
    exit 1
fi

rm -f $HOME/*.apk
rm -f $HOME/*.sh
echo "Clean up old files done."

wget -O $HOME/download.sh "https://raw.githubusercontent.com/thutrang0410/vietbot/main/download.sh"
wget -O $HOME/install.sh "https://raw.githubusercontent.com/thutrang0410/vietbot/main/install.sh"
wget -O $HOME/dlna-uni.sh "https://raw.githubusercontent.com/thutrang0410/vietbot/main/dlna-uni.sh"
chmod +x $HOME/download.sh
chmod +x $HOME/install.sh
chmod +x $HOME/dlna-uni.sh

echo "[1/3] Chuan bi cai dat..."
$HOME/download.sh
echo "[2/3] Cai dat Voicebot..."
$HOME/install.sh || true
echo "[3/3] Cai dat DLNA va Unisound..."
$HOME/dlna-uni.sh 192.168.43.1:5555
echo "Cai dat hoan tat."
echo "Doi thiet bi khoi lai xong."
echo "Vao wifi Phicomm R1, truy cap http://192.168.43.1:8081 de cau hinh Wi-Fi cho thiet bi."
