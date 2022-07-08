#!/bin/bash

# ssh into the server and deploying the app
ssh -i "private_key.pem" ubuntu@ip_address 'cd; rm -rf assessment; git clone https://github.com/baldehalfa/assessment.git; cd assessment; docker build . -t express-app:v1; docker run -d -p 3000:3000 express-app:v1'