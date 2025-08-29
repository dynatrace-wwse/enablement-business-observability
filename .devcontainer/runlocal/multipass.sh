#!/bin/bash
# Helper script for setting up the Ubuntu machine with comfort functions and installing the necesary tools.
# Install Docker and dependencies (buildx)?
# PS1


setPS1(){
echo "Setting up PS1 to show the git information in .bashrc..."
cat <<EOF >> ~/.bashrc
## git branch
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "
EOF
}

setupAliases() {
  echo "Adding Bash and Kubectl Pro CLI aliases to the end of the .bashrc for user $USER "
  echo "
# Alias for ease of use of the CLI
alias las='ls -las' 
alias c='clear' 
alias hg='history | grep' 
alias h='history' 
alias gita='git add -A'
alias gitc='git commit -s -m'
alias gitp='git push'
alias gits='git status'
alias gith='git log --graph --pretty=\"%C(yellow)[%h] %C(reset)%s by %C(green)%an - %C(cyan)%ad %C(auto)%d\" --decorate --all --date=human'
alias vaml='vi -c \"set syntax:yaml\" -' 
alias vson='vi -c \"set syntax:json\" -' 
alias pg='ps -aux | grep' 
" >> /"$HOME"/.bashrc
}

setPS1
setupAliases


draftStuff(){
  
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

}