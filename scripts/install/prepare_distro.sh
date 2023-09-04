#!/usr/bin/env bash

cd ~ || exit 1

github_username=$1
github_token_path=$(echo "$2" | sed -e 's/\\/\//g' -e 's/^\(\w\):/\/mnt\/\L\1/')

echo "Upgrade all packages"
sudo apt update
apt upgrade -y

echo "Copy github token"
mkdir -p ~/.config/github
cp "$github_token_path" ~/.config/github/token

echo "Copy ssh files from Windows host"
cp -r /mnt/c/Users/c.herrmann/.ssh ~/
chmod 700 ~/.ssh
find ~/.ssh/ -type f -exec chmod 600 {} \;

echo "Installing git"
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt update
sudo apt install -y git

echo "Installing ansible"
sudo add-apt-repository -y ppa:ansible/ansible
sudo apt update
sudo apt install -y ansible

echo "Populate ansible hosts file"
[ -d /etc/ansible ] || sudo mkdir /etc/ansible
echo "localhost ansible_connection=local" | sudo tee /etc/ansible/hosts > /dev/null

echo "Installing ansible collection wecg/dev_env"
ansible-galaxy collection install git@github.com:Elektroshop/ansible.git#wecg/dev_env,dev
ansible-galaxy collection install git@github.com:Elektroshop/ansible.git#wecg/dev_env,dev

echo "Run setup for development environment"
ansible-playbook -e "github_user=$github_username github_token=$github_token_path" wecg.dev_env.setup
