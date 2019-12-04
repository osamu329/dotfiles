#!/bin/bash
SCRIPT_DIR=$(cd $(dirname $0); pwd)
mkdir -p $SCRIPT_DIR/downloads
source resources.txt
mkdir -p ~/.local/bin/
mkdir -p ~/.local/share/
mkdir -p ~/.config/nvim/
mkdir -p ~/go && echo create GOPATH $HOME/go

# tmux
#
if !(type -t tmux); then
	echo Install tmux
	sudo apt install -y tmux
fi

ln -s -f ~/.dotfiles/tmux.conf ~/.tmux.conf && echo Install tmux.conf

# go
PATH=~/.local/bin:~/.local/go/bin:$PATH

if !(type "curl" > /dev/null 2>&1); then
	sudo apt install -y curl
fi

git submodule init && git submodule update

if !(type "go" > /dev/null 2>&1); then
	if !(sha256sum downloads/$(basename $GOURL)); then
		curl $GOURL -L -o downloads/$(basename $GOURL)
	fi
	tar zxf downloads/$(basename $GOURL) -C $HOME/.local/
	if !(type "go" > /dev/null 2>&1);then
	    echo Please install go in ~/.local/go/
	    exit 1
	fi
else
    echo Go found in `which go`
fi

# neovim
#
ln -s -f $SCRIPT_DIR/init.vim ~/.config/nvim/ && echo Install init.vim

if !(type -t nvim); then
	if !(cd downloads;sha256sum --check $NVIM_SHA256); then
		curl $NVIM_URL -L -o downloads/$(basename $NVIM_URL)
	fi
	tar zxf downloads/$(basename $NVIM_URL) -C $HOME/.local/
	mv $HOME/.local/nvim-linux64/bin/nvim $HOME/.local/bin/nvim
	mv $HOME/.local/nvim-linux64/share/* $HOME/.local/share/
fi

if type -t nvim; then
    nvim -c "call dein#install()" -c quit
fi



# .bashrc
#
if grep dotfiles/bashrc $HOME/.bashrc; then
    echo Install bashrc
else
    echo "source $HOME/.dotfiles/bashrc" >> $HOME/.bashrc
fi

# ddnsupdate
#
go build -o ~/.local/bin/ddnsupdate ./src/ddnsupdate.go && echo Install ddnsupdate in ~/.local/bin


