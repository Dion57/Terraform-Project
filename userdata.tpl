#!/bin/bash

# Update package lists and install required packages
sudo apt-get update -y && \
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker repository to apt sources
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update package lists again
sudo apt-get update -y

# Install Docker CE and containerd
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

# Add the current user to the docker group
sudo usermod -aG docker ubuntu
