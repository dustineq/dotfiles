#!/bin/sh

whatif=
force=
verbose=0 # Variables to be evaluated as shell arithmetic should be initialized to a default or validated beforehand.
scriptroot=$(cd -- "$(dirname -- "$0")" && pwd)
dotfiles=$(cd -- "$scriptroot/.." && pwd)
cd "$scriptroot" || exit 1
retc=0 # return code

variation=unix
if [ "$(uname -s)" = "Darwin" ]; then variation=darwin; fi

show_help() { cat << EOF
bootstrap.sh - Farms symlinks to configure a machine for this dotfiles repository.

Creates symlinks in \$HOME, \$XDC_CONFIG_HOME and other locations to configure
a machine for this dotfiles repository.

Options:
	-h|--help 	Show this help message.
	-w|--whatif 	Output what would be changed.
	-v|--verbose	Adds verbosity to output.
EOF
}

while :; do
    case $1 in
        -h|-\?|--help)   # Call a "show_help" function to display a synopsis, then exit.
            show_help
            exit
            ;;
        -f|--force)
			force=1
            ;;
        -w|--whatif)
			whatif=1
            ;;
        -v|--verbose)
            verbose=$((verbose + 1)) # Each -v argument adds 1 to verbosity.
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'Unknown option (ignored): %s\n' "$1" >&2
			exit 1
            ;;
        *)               # Default case: If no more options then break out of the loop.
            break
    esac

    shift
done

if [ $whatif ]; then w='(whatif) '; fi
log() { printf "%s%s\n" "$w" "$1"; }
info() { [ $verbose -gt 0 ] && printf "%s\n" "$1"; }
warn() { printf "WARN: %s\n" "$1"; }

# Transform templates
copyTemplate () {
	if [ $force ]; then
		rm "$1"
		cp "$1" "$2"
	elif [ ! -f "$2" ]; then
		log "Copying Template: $2"; 
		if [ ! $whatif ]; then cp "$1" "$2"; fi
	fi
}

handleLink () {
	log "Handling link from $1 to $2"

	l=$1 # link
	f=$2 # pointing to target
	lv=$(readlink "$l") # symlink value

	if [ $force ]; then
		rm "$l"
		ln -s "$f" "$l"
	elif [ -L "$l" ] && [ "$lv" = "$f" ]; then
		info "No Changes to symlink $l"
	elif [ -L "$l" ] && [ "$lv" != "$f" ]; then
		warn "Unexpected value for symlink: $l"
		echo "$f $lv"
		retc=1
	elif [ ! -e "$l" ]; then
		log "Create symlink: $l"
		if [ ! $whatif ]; then ln -s "$f" "$l"; fi
	else
		warn "Existing item at symlink destination: $l"
		retc=1
	fi
}

# Environmental prerequisites
[ ! -d "$HOME/.config" ] && mkdir -p "$HOME/.config"; # non-standard xdc path?
[ ! -d "$HOME/.local/share" ] && mkdir -p "$HOME/.local/share"; # non-standard xdc path?

copyTemplate "$dotfiles/git/.gitconfig_local.template" "$dotfiles/dot_gitconfig_local"
copyTemplate "$dotfiles/.config/nvim/local.dotfiles.vim.template" "$dotfiles/.config/nvim/local.dotfiles.vim"
copyTemplate "$dotfiles/dot_vim/.vimrc.local.template" "$dotfiles/dot_vimrc.local"

# Local links
f="$dotfiles/git/.gitconfig_os_$variation"
l="$dotfiles/dot_gitconfig_os"
handleLink "$l" "$f"

handleLink "$HOME/.dotfiles" "$dotfiles"
handleLink "$HOME/.config/dotfiles_shell" "$dotfiles/.config/dotfiles_shell"
handleLink "$HOME/.config/kitty" "$dotfiles/.config/kitty"
handleLink "$HOME/.config/nvim" "$dotfiles/.config/nvim"
handleLink "$HOME/.config/powershell" "$dotfiles/.config/powershell"
handleLink "$HOME/.config/zsh" "$dotfiles/.config/zsh"
handleLink "$HOME/.local/share/powershell/Scripts" "$dotfiles/PSScripts"

# Item list to be symlinked.
#find "$dotfiles" -name 'dot_*' -o -path "$dotfiles/.config/*" -o -path "$dotfiles/PSScripts" -maxdepth 2 | while read -r f; do
for f in "$dotfiles"/dot_*
do
	# Get item information.
	r=$(readlink -f "$f")
	r=$(basename -- "$r")
	r=$(echo "$r" | sed "s/dot_/./") # transform dot_ to .

	# Transform items
    l="$HOME/$r" # symlink file path

	echo "Handling link from $l to $f"
	handleLink "$l" "$f"
done

exit $retc
