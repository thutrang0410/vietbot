#!/bin/sh

rm -f $HOME/*.apk
rm -f $HOME/*.sh
echo "Clean up old files done."

wget -O $HOME/tai-files.sh "https://raw.githubusercontent.com/thutrang0410/vietbot/main/tai-files.sh"
wget -O $HOME/cai-dat-ai.sh "https://raw.githubusercontent.com/thutrang0410/vietbot/main/cai-dat-ai.sh"
wget -O $HOME/cai-dat-dlna-unisound.sh "https://raw.githubusercontent.com/thutrang0410/vietbot/main/cai-dat-dlna-unisound.sh"
chmod +x $HOME/tai-files.sh
chmod +x $HOME/cai-dat-ai.sh
chmod +x $HOME/cai-dat-dlna-unisound.sh

echo "[1/3] Chuan bi cai dat..."
$HOME/tai-files.sh
echo "[2/3] Cai dat Voicebot..."
$HOME/cai-dat-ai.sh || true
echo "[3/3] Cai dat DLNA va Unisound..."
$HOME/cai-dat-dlna-unisound.sh 192.168.43.1:5555
echo "Cai dat hoan tat."
echo "Doi thiet bi khoi lai xong."
echo "Vao wifi Phicomm R1, truy cap http://192.168.43.1:8081 de cau hinh Wi-Fi cho thiet bi."
