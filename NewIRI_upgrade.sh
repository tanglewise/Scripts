
#!/bin/bash
sudo service iotapm stop && sudo service nelson stop && sudo service iota stop
sudo apt-get -y install maven
cd /home/iota
sudo git clone https://github.com/tanglewise/NewIRI.git
cd NewIRI
sudo git pull origin
cd /home/iota/NewIRI/
sudo mvn clean compile
sudo mvn package
sudo rm /home/iota/node/iri-1.4.2.4.jar

#Get RAM, create java RAM constraint flag variable
phymem=$(awk -F":" '$1~/MemTotal/{print $2}' /proc/meminfo )
phymem=${phymem:0:-2}
#allot about 75% of RAM to java
phymem=$((($phymem/1333) + ($phymem % 1333 > 0)))
xmx="Xmx"
xmx_end="m"
xmx=$xmx$phymem$xmx_end

#change jar file name
sudo rm /lib/systemd/system/iota.service
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

#increase num neighbors
sudo rm /home/nelson/config.ini
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

#copy jar file
sudo cp /home/iota/NewIRI/target/iri-1.4.2.4.jar /home/iota/node/
sudo curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g npm
sudo service iota start && sudo service nelson start && sudo service iotapm start
