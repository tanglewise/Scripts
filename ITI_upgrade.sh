#!/bin/bash

cd /home/iota/tanglewise/
sudo git pull origin master
cd iri
sudo mvn clean compile
sudo mvn package
sudo rm /home/iota/node/iri-1.4.2.2.jar
sudo cp /home/iota/tanglewise/iri/target/iri-1.4.2.2.jar /home/iota/node/

#Restart node
sudo service iota stop && sudo service nelson stop && sudo service iotapm stop
sudo service iota start && sudo service nelson start && sudo service iotapm start