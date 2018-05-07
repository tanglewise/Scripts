#!/bin/bash
sudo service iotapm stop && sudo service nelson stop && sudo service iota stop
sudo apt-get -y install maven
cd /home/iota
sudo git clone https://github.com/tanglewise/ITI.git
cd ITI
sudo git pull origin
#sudo git checkout testnet_tip_selection
cd /home/iota/ITI/iri
sudo mvn clean compile
sudo mvn package
sudo rm /home/iota/node/iri-1.4.2.4.jar
sudo cp /home/iota/ITI/iri/target/iri-1.4.2.4.jar /home/iota/node/
sudo curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g npm
#Restart node
sudo service iota start && sudo service nelson start && sudo service iotapm start
