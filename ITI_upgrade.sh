#!/bin/bash
sudo service iota stop && sudo service nelson stop && sudo service iotapm stop
sudo apt-get install maven
cd /home/iota
sudo git clone https://github.com/tanglewise/ITI.git
cd ITI
sudo git pull origin
sudo git checkout testnet_tip_selection
cd /home/iota/ITI/iri
sudo mvn clean compile
sudo mvn package
sudo rm /home/iota/node/iri-1.4.2.4.jar
sudo cp /home/iota/ITI/iri/target/iri-1.4.2.4.jar /home/iota/node/
#Restart node
sudo service iota start && sudo service nelson start && sudo service iotapm start