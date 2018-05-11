#!/bin/bash
sudo service iotapm stop && sudo service nelson stop && sudo service iota stop
sudo apt-get -y install maven
sudo rm /home/iota/node/iri-1.4.2.4.jar
sudo -u iota wget -O /home/iota/node/iri-1.4.2.4.jar https://github.com/iotaledger/iri/releases/download/v1.4.2.4/iri-1.4.2.4.jar
sudo curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g npm
#Restart node
sudo service iota start && sudo service nelson start && sudo service iotapm start
