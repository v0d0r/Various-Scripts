#!/bin/bash

# auther: kevin
# overview: slapped together all the aws eks commands to setup a kubectl client
# last modified: 06.12.2018
# dependencies: various aws stuff all in the script. most important python 2.7 on your pc
# todo: n/a

# install kubectl from amazon
echo "downloading and installing kubectl from aws"
curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
kubectl version --short --client
echo "kubectl installed"

# install aws-iam-authenticator
echo "downloading and installing aws-iam-authenticator"
wget https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
aws-iam-authenticator help
echo "aws-iam-authenticator installed"

# install aws-cli
echo "downloading and installing aws-cli from bundle NOTE: sudo access required"
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
echo "SUDO PASSWORD WILL BE REQUIRED NEXT"
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
aws --version

# configure aws and kubectl
echo "next manual steps are to configure aws-cli and kubectl to work together"
echo "NOTE YOU WILL NEED YOUR IAM USER KEY AND SECRET FROM THE IAM CONSOLE"
echo "IF YOU DO NOT HAVE THIS NOW IS A GOOD TIME TO CREATE IAM USERS FIRST"
aws configure
echo "AWS Configure Done"

# aws eks update-kubeconfig
echo "update eks cluster with relevant iam details and what not"
aws eks update-kubeconfig --name t200
echo "cluster info to follow shortly from kubectl cluster-info command"
kubectl cluster-info


