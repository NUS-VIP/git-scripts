#!/bin/bash

#Usage: cmd genkey - to generate SSH key
#       cmd test   - verify if github is enabled successfully
#       cmd 

cmd=$1

if [ "$cmd" = "test" ]; then

    echo -e "Testing With Github account..."
    echo -e "You will see message like below: "
    echo -e "   *The authenticity of host 'github.com (207.97.227.239)' can't be established. RSA key fingerprint is .... Are you sure you want to continue connecting (yes/no)?*"
    echo -e "This is normal. Please input yes. Then you will get succesful authentication. "
    echo -e "Hi XXX! You've successfully authenticated, but GitHub does not provide shell access."
    echo "***************************"
    ssh -T git@github.com
    exit

else
    #test if the .ssh key folder exists
    ls -al ~/.ssh 2&>1 >> /dev/null
    if [ `echo $?` != "2" ]; then
        echo -e "Warning: ~/.ssh already exits!\nAll previous generated ssh keys will lost!"
        read -p "Press any key to continue... " -n1 -s   
    fi

    #read github account
    echo -e "\nPlease input your email as github account : "
    read email
    echo "$email will be used for your git account"
    read -p "Press any key to continue... " -n1 -s

    #creats a new ssh key
    ssh-keygen -t rsa -C "$email" 
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa

    echo "*********************************************************************"
    echo "Please copy the below contents and add to SSH Keys in github Account settings"
    echo "*********************************************************************"
    cat ~/.ssh/id_rsa.pub

    echo "*********************************************************************"
    echo "Copy the text above. Open a browser, login Github->Account Settings->SSH Keys->Add SSH Key, and paste the text into the SSH key content. Give the key a title that reminds you where the machine is."
fi





