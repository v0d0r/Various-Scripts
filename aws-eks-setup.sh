#!/bin/bash

# auther: kevin
# overview: slapped together all the aws eks commands to setup a kubectl client
# last modified: 06.12.2018
# dependencies: various aws stuff all in the script. most important python 2.7 on your pc
# todo: n/a

# set some variables
clustername="transact-poc-eks"

# install kubectl from amazon
echo ""
echo "This script will download and install kubectl for aws, aws-authenticator and aws-cli."
echo "This is all the tools required to interface with AWS via kubectl and setup configure"
echo "an existing cluster"
echo "NOTE: Have not tested this with existing kubectl to be save backup your home"
echo ".kube folder before running this script"
echo ""
read -p "Press [Enter] to continue"
echo ""
echo "----------------------------------------------------------------"
echo "downloading and installing kubectl from aws"
echo "----------------------------------------------------------------"
echo ""
curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
kubectl version --short --client
echo ""
echo "----------------------------------------------------------------"
echo "kubectl installed"
echo "----------------------------------------------------------------"
echo ""
# install aws-iam-authenticator
echo "----------------------------------------------------------------"
echo "downloading and installing aws-iam-authenticator"
echo "----------------------------------------------------------------"
echo ""
wget https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
aws-iam-authenticator help
echo ""
echo "----------------------------------------------------------------"
echo "aws-iam-authenticator installed"
echo "----------------------------------------------------------------"
echo ""
# install aws-cli
echo "--------------------------------------------------------------------------"
echo "downloading and installing aws-cli from bundle NOTE: sudo access required"
echo "--------------------------------------------------------------------------"
echo ""
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
echo ""
echo "----------------------------------------------------------------"
echo "SUDO PASSWORD WILL BE REQUIRED NEXT"
echo "----------------------------------------------------------------"
echo ""
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
aws --version
echo ""
# configure aws and kubectl
echo "--------------------------------------------------------------------------"
echo "next manual steps are to configure aws-cli and kubectl to work together"
echo "NOTE YOU WILL NEED YOUR IAM USER KEY AND SECRET FROM THE IAM CONSOLE"
echo "IF YOU DO NOT HAVE THIS NOW IS A GOOD TIME TO CREATE IAM USERS FIRST"
echo "Use AWS Access Key ID & AWS Secret Access Key provided via email"
echo "Default region for POC use us-east-2"
echo "Default output format json"
echo "--------------------------------------------------------------------------"
echo ""
aws configure
echo "---------------------"
echo "AWS Configure Done"
echo "---------------------"
echo ""
# aws eks update-kubeconfig
echo "-----------------------------------------------------------"
echo "update eks cluster with relevant iam details and what not"
echo "-----------------------------------------------------------"
echo ""
aws eks update-kubeconfig --name $clustername
echo ""
echo "-----------------------------------------------------------------"
echo "cluster info to follow shortly from kubectl cluster-info command"
echo "-----------------------------------------------------------------"
echo ""
kubectl cluster-info


