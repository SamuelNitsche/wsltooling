#!/usr/bin/env bash

cd ~ || exit 1

github_username=$1
github_token_path=$(echo "$2" | sed -e 's/\\/\//g' -e 's/^\(\w\):/\/mnt\/\L\1/')
git_user_name="$3"
git_user_email="$4"
windows_home_dir=$(echo "$5" | sed -e 's/\\/\//g' -e 's/^\(\w\):/\/mnt\/\L\1/')

echo "Upgrade all packages"
sudo apt update
sudo apt upgrade -y

echo "Copy github token"
mkdir -p ~/.config/github
cp "$github_token_path" ~/.config/github/token

echo "Copy ssh files from Windows host"
cp -r "$windows_home_dir"/.ssh ~/
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
ansible-galaxy collection install git@github.com:Elektroshop/ansible.git#wecg/general,dev

echo "Installing ansible dependencies for wecg/dev_env"
ansible-galaxy role install geerlingguy.apache geerlingguy.apache-php-fpm geerlingguy.mysql geerlingguy.php geerlingguy.php-versions

echo "Run setup for development environment"
ansible-playbook -e "github_user=$github_username github_cli_authenticate_deviant_token_path=~/.config/github/token git_user_name=$git_user_name git_user_email=$git_user_email" wecg.dev_env.setup
