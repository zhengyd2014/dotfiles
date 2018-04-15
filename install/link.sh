#!/usr/local/bin/bash

DOTFILES=$HOME/dotfiles

declare -A links
echo -e "\nCreating symlinks"
echo "=============================="
linkables=$( find -H "$DOTFILES" -maxdepth 3 -name '*.symlink' )
for file in $linkables ; do
    target="$HOME/.$( basename $file ".symlink" )"
	links[$file]=$target
done

links[$HOME/dotfiles/ssh/config]=$HOME/.ssh/config



# for file in "${!links[@]}" ; do
# 	echo $file = ${links[$file]}
# done
# 

for file in "${!links[@]}" ; do
    if [ -e  ${links[$file]} ]; then
        echo "~${links[$file]#$HOME} already exists... Skipping."
    else
        echo "Creating symlink for ${links[$file]}"
        ln -s $file ${links[$file]}
    fi
done