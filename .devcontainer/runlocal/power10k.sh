#!/bin/bash 
# Braindump for adding style and functionality to the shell in Multipass and Codespaces


sudo apt update
sudo apt install zsh -y


# make default?
chsh -s $(which zsh)

#install OhMyZsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"


https://github.com/romkatv/powerlevel10k#instant-prompt
# Below here maybe jsut copy structure a
# nd files after configuration takes place
# -----
# edit zshrc
nano ~/.zshrc
ZSH_THEME="powerlevel10k/powerlevel10k"
# Apply changes
source ~/.zshrc
# Configure
p10k configure

~/.p10k.zsh?
