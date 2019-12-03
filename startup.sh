#!/bin/bash

mkdir -p ~/.local/bin/
mkdir -p ~/.config/nvim/
mkdir -p ~/go && echo create GOPATH $HOME/go

git submodule init && git submodule update

if !(type "go" > /dev/null 2>&1); then
    echo Please install go in ~/.local/go/
    exit 1
else
    echo Go found in `which go`
fi

ln -s -f ~/init.vim ~/.config/nvim/ && install init.vim

if type nvim; then
    nvim -c "call dein#install()"
fi


# tmux.conf
#
ln -s -f ~/.dotfiles/tmux.conf ~/.tmux.conf & install tmux.conf

# .bashrc
#
if grep dotfiles/bashrc $HOME/.bashrc; then
    echo install bashrc
else
    echo "source $HOME/.dotfiles/bashrc" >> $HOME/.bashrc
fi

# ddnsupdate
#
go build -o ~/.local/bin/ddnsupdate ./src/ddnsupdate.go && echo install ddnsupdate in ~/.local/bin


