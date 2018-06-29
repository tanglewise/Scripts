#!/bin/bash

#Download required packages
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get -y install software-properties-common -y && sudo add-apt-repository ppa:webupd8team/java -y && sudo apt update && sudo apt install oracle-java8-installer curl wget jq git -y && sudo apt install oracle-java8-set-default -y
sudo sh -c 'echo JAVA_HOME="/usr/lib/jvm/java-8-oracle" >> /etc/environment' && source /etc/environment
sudo useradd -s /usr/sbin/nologin -m iota
sudo -u iota mkdir -p /home/iota/node /home/iota/node/ixi /home/iota/node/mainnetdb /home/iota/tanglewise
sudo -u iota git clone https://github.com/tanglewise/ITI.git /home/iota/tanglewise

#Install maven and build ITI
sudo apt-get -y install maven
cd /home/iota/tanglewise/ITI/
sudo mvn clean compile
sudo mvn package
sudo cp /home/iota/tanglewise/ITI/target/iri-1.4.2.4.jar /home/iota/node/

#Get RAM, create java RAM constraint flag variable
phymem=$(awk -F":" '$1~/MemTotal/{print $2}' /proc/meminfo )
phymem=${phymem:0:-2}
#allot about 75% of RAM to java
phymem=$((($phymem/1333) + ($phymem % 1333 > 0)))
xmx="Xmx"
xmx_end="m"
xmx=$xmx$phymem$xmx_end

#Enable IOTA node as a service
cat << EOF | sudo tee /lib/systemd/system/iota.service
[Unit]
Description=IOTA IRI full node
After=network.target
[Service]
WorkingDirectory=/home/iota/node
User=iota
PrivateDevices=yes
Type=simple
ExecReload=/bin/kill -HUP $MAINPID
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=60
ExecStart=/usr/bin/java -$xmx -Djava.net.preferIPv4Stack=true -jar iri-1.4.2.4.jar -c iota.ini
Restart=on-failure
RestartSec=30
[Install]
WantedBy=multi-user.target
Alias=iota.service
EOF
sudo systemctl daemon-reload && sudo systemctl enable iota.service

#Configure node settings
cat << EOF | sudo -u iota tee /home/iota/node/iota.ini
[IRI]
PORT = 14265
UDP_RECEIVER_PORT = 14600
TCP_RECEIVER_PORT = 15600
API_HOST = 0.0.0.0
IXI_DIR = ixi
HEADLESS = true
DEBUG = false
TESTNET = false
DB_PATH = mainnetdb
RESCAN_DB = false
MIN_RANDOM_WALKS = 1
REMOTE_LIMIT_API="removeNeighbors, addNeighbors, interruptAttachingToTangle"
NEIGHBORS = udp://94.156.128.15:14600 udp://185.181.8.149:14600
EOF

cd /tmp/
sudo curl -O http://db.iota.partners/IOTA.partners-mainnetdb.tar.gz
sudo -u iota tar xzfv /tmp/IOTA.partners-mainnetdb.tar.gz -C /home/iota/node/mainnetdb
sudo rm /tmp/IOTA.partners-mainnetdb.tar.gz
sudo service iota start

echo '*/15 * * * * root bash -c \"bash <(curl -s https://gist.githubusercontent.com/zoran/48482038deda9ce5898c00f78d42f801/raw)\"' | sudo tee /etc/cron.d/iri_updater > /dev/null

#Install Nelson for automatic neighbors
sudo curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g nelson.cli@0.3.16
sudo npm install -g iota-pm > /dev/null
sudo useradd -s /usr/sbin/nologin -m nelson
cat << EOF | sudo -u nelson tee /home/nelson/config.ini
[nelson]
cycleInterval = 60
epochInterval = 300
IRIProtocol = any
apiPort = 18600
apiHostname = 127.0.0.1
port = 16600
IRIHostname = 127.0.0.1
IRIPort = 14265
TCPPort = 15600
UDPPort = 14600
incomingMax = 9
outgoingMax = 8
dataPath = data/neighbors.db
isMaster = false
silent = false
gui = false
getNeighbors = https://raw.githubusercontent.com/SemkoDev/nelson.cli/master/ENTRYNODES
neighbors[] = mainnet.deviota.com/16600
neighbors[] = mainnet2.deviota.com/16600
neighbors[] = mainnet3.deviota.com/16600
neighbors[] = iotairi.tt-tec.net/16600
EOF

#Enable Nelson service
cat << EOF | sudo tee /lib/systemd/system/nelson.service
[Unit]
Description=CarrIOTA Nelson
After=network.target
[Service]
WorkingDirectory=/home/nelson
User=nelson
PrivateDevices=yes
Type=simple
ExecReload=/bin/kill -HUP $MAINPID
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=60
ExecStart=/usr/bin/nelson --config /home/nelson/config.ini
Restart=on-failure
RestartSec=30s
[Install]
WantedBy=multi-user.target
Alias=nelson.service
EOF
sudo systemctl daemon-reload && sudo systemctl enable nelson.service
sudo service nelson start

#Enable IOTA peer manager service
cat << EOF | sudo tee /lib/systemd/system/iotapm.service
[Unit]
Description=Iota Peer Manager
After=network.target
[Service]
WorkingDirectory=/home/iota
User=iota
PrivateDevices=yes
Type=simple
ExecReload=/bin/kill -HUP $MAINPID
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=60
ExecStart=/usr/bin/iota-pm -i http://127.0.0.1:14265 -p 127.0.0.1:9999
Restart=on-failure
RestartSec=30
[Install]
WantedBy=multi-user.target
Alias=iotapm.service
EOF
sudo systemctl daemon-reload && sudo systemctl enable iotapm.service
sudo service iotapm start

#Install python jupyter notebook
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install python3-pip -y && sudo apt purge python2.7-minimal -y && sudo pip3 install jupyter && sudo pip3 install ipyparallel && sudo pip3 install pyota && sudo pip3 uninstall pyopenssl -y && sudo pip3 install pyopenssl && sudo pip3 install pyota[ccurl]
