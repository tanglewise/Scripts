#!/bin/bash

cd /home/iota/tanglewise/
sudo git pull origin master
cd iri
sudo mvn clean compile
sudo mvn package
sudo cp /home/iota/tanglewise/iri/target/iri-1.4.2.2.jar /home/iota/node/

#Restart node
sudo service iota stop && sudo service nelson stop && sudo service iotamp stop
sudo service iota start && sudo service nelson start && sudo service iotamp start