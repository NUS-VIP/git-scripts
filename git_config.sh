#!/bin/bash


#read github account
echo -e "\nPlease input your user name to be shown in commits : "
read user
echo "Please input your user email to be shown in commits"
read email
echo "$user:$email will be your git signature"



#config git user name
git config --global push.default matching
git config --global user.name "$user"
git config --globa user.email "$email"
#cache your github password for some time period (now is 7776000 secs=90 days ) you need git 1.7.10 or higher to support this
git config --global credential.helper 'cache --timeout=7776000'
