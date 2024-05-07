#!/bin/bash
iatest=$(expr index "$-" i)

#######################################################
# EXPORTS
#######################################################

# Disable the bell
if [[ $iatest -gt 0 ]]; then bind "set bell-style visible"; fi

# Expand the history size
export HISTFILESIZE=10000
export HISTSIZE=500

# Don't put duplicate lines in the history and do not add lines that start with a space
export HISTCONTROL=erasedups:ignoredups:ignorespace

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
shopt -s histappend
PROMPT_COMMAND='history -a'

# Allow ctrl-S for history navigation (with ctrl-R)
[[ $- == *i* ]] && stty -ixon

# Ignore case on auto-completion
# Note: bind used instead of sticking these in .inputrc
if [[ $iatest -gt 0 ]]; then bind "set completion-ignore-case on"; fi

# Show auto-completion list automatically, without double tab
if [[ $iatest -gt 0 ]]; then bind "set show-all-if-ambiguous On"; fi


# Path Customization
if [ -d "$HOME/.bin" ]; then
  PATH="$HOME/.bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/Applications" ]; then
  PATH="$HOME/Applications:$PATH"
fi

if [ -d "/var/lib/flatpak/exports/bin/" ]; then
  PATH="/var/lib/flatpak/exports/bin/:$PATH"
fi

# Autojump setup
if [ -f "/usr/share/autojump/autojump.sh" ]; then
  . /usr/share/autojump/autojump.sh
elif [ -f "/usr/share/autojump/autojump.bash" ]; then
  . /usr/share/autojump/autojump.bash
else
  echo "Error: Can't find the autojump script"
fi

# To have colors for ls and all grep commands such as grep, egrep and zgrep
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'
#export GREP_OPTIONS='--color=auto' #deprecated
alias grep="/usr/bin/grep $GREP_OPTIONS"
unset GREP_OPTIONS

# Color for manpages in less makes manpages a little easier to read
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Terminal Settings
export TERM="xterm-256color"
export EDITOR=nano

# Aliases for File and Directory Operations
alias ll='ls -all --color=auto -h'
alias cp='cp -i'
alias mv='mv -i'
alias rm='trash -v'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'
alias cls='clear && colorscript -r'
alias clear='/bin/clear && colorscript -r'



# human readable sizes
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB

# Colorize Grep Output
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Display Open Ports
alias openports='netstat -nape --inet'

# Reboot Aliases
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'
# GIT Customizations
gitpush() {
    git add .
    git commit -m "$*"
    git pull
    git push
}

gitupdate() {
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/github
    ssh -T git@github.com
}

git-push() {
    git add .
    git commit -m "$1"
    git push
}

gitcommit() {
    git add .
    git commit -m "$1"
}

extract() {
	for archive in "$@"; do
		if [ -f "$archive" ]; then
			case $archive in
			*.tar.bz2) tar xvjf $archive ;;
			*.tar.gz) tar xvzf $archive ;;
			*.bz2) bunzip2 $archive ;;
			*.rar) rar x $archive ;;
			*.gz) gunzip $archive ;;
			*.tar) tar xvf $archive ;;
			*.tbz2) tar xvjf $archive ;;
			*.tgz) tar xvzf $archive ;;
			*.zip) unzip $archive ;;
			*.Z) uncompress $archive ;;
			*.7z) 7z x $archive ;;
			*) echo "don't know how to extract '$archive'..." ;;
			esac
		else
			echo "'$archive' is not a valid file!"
		fi
	done
}

# Aliases for GIT
alias gp='gitpush'
alias gu='gitupdate'
alias gpush='git-push'
alias gcommit='gitcommit'



# Cache Fix
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Batcat
alias cat='bat'

# FC-list Customization
# custom fc-list
# - sort list
# - add color
# - format table output
function fc-list () {
  # if calling with arguments, call the original command
  if [[ "$#" -gt 0 ]]; then
    command fc-list "$@"
    return $?
  fi

  # prepend header
  {
    echo "FILE:FAMILY:STYLE"
    command fc-list "$@" 
  } | \
  sort | \
  # replace weird space after colon after file name
  sed -E 's/: /:/g' | \

  # pretty print the file path, and other field fixes
  command awk -F: '
  BEGIN {
    green="\033[32m";
    white="\033[0m";
    bold="\033[1m";
    reset="\033[0m";
  }
  function pretty_print_directory(path) {
    last_slash = match(path, /\/[^\/]+$/);
    directory = substr(path, 1, last_slash);
    file = substr(path, last_slash + 1);

    # print the directory in green, and the file in white and bold
    return green directory white bold file reset;
  }
  {
    # skip header row, but make every field bold
    if (NR == 1) {
      OFS=":";
      for (i = 1; i <= NF; i++) {
        $i = bold $i reset;
      }
      print $0;
      next;
    }
    OFS=":";
    $1 = pretty_print_directory($1);

    # remove "style=" prefix from 3rd field
    sub(/^style=/, "", $3);

    # if third field (styles) consist of 3+ comma separated values, print only
    # the first
    # two followed by "..."
    if (match($3, /,[^,]+,[^,]+$/)) {
      $3 = gensub(/^([^,]+,[^,]+).*/, "\\1, ...", 1, $3);
    }

    print $0;
  }' | \
  column -t -s: | \
  less -S
}

alias fonts="fc-list"

# fc-list-families
# - list only the font families in the system
function fc-list-families () {
  command fc-list : family | sort
}
alias font-families="fc-list-families"


# History settings
HISTFILE=~/.bash-history
HISTSIZE=SAVEHIST=10000


