# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="gentoo"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=90

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

# User configuration

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
export PATH="/opt/SEGGER/JLink:$PATH"
export PATH="/opt/nordic:$PATH"
export PATH="$PATH:/opt/esp-open-sdk/xtensa-lx106-elf/bin"
export PATH="$PATH:/opt/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin"
export PATH="$PATH:/opt/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu/bin"
export PATH="/opt/depot_tools:$PATH"
export PATH="$PATH:/home/hottuna/.cargo/bin"
export PATH="$PATH:/home/hottuna/.local/bin"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias lg="log --graph --pretty=format:'%Cred%h%Creset - %C(bold blue)%an%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)' --abbrev-commit"
alias ll="ls -lah"
alias weechat="mosh -p 11500:16000 --ssh=\"ssh -p 11000\" k.xil.se -- screen -D -RR weechat weechat-curses"

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

export TERM=xterm-256color
export ALT_LOCAL=/opt/local
export ACLOCAL="aclocal -I $ALT_LOCAL/share/aclocal"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$ALT_LOCAL/lib/pkgconfig"

export USE_CCACHE=1
export CCACHE_DIR=/opt/.ccache
export CCACHE_COMPRESS=true

## Allgone uploader
function allgone()
{
for OUTPUT in "$@"
do
  echo $(curl --progress-bar -F secret=julmust -F userfile=@"$OUTPUT" https://allg.one/index.php)
done
}

## transfer.sh uploader
transfer() {
  if [ $# -eq 0 ]; then
    echo "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md";
    return 1;
  fi
  tmpfile=$( mktemp -t transferXXX );
  if tty -s; then
    basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g');
    curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile;
  else
    curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile;
  fi;
  cat $tmpfile;
  rm -f $tmpfile;
};
alias transfer=transfer 

## Simplify grep command
# Remove alias introduced by git oh-my-zsh plugin.
unalias gg 2>/dev/null
gg(){
  eval "grep -Rn \"$@\" ."
}

## Replace in files recursively
replace_files(){
  grep -rl $1 . | xargs sed -i "s/$1/$2/g"
}

## Run command until it fails
rerun_fail() {
  while $@; do :; done
}

## Run command until it fails
rerun_pass() {
$@
  while [ $? -ne 0 ]; do
    $@;
  done
}

## Retry running a function until it succeeds
## retry $nbr_retries $command [command arguments]
rerun(){
  if [[ "$@" == "" ]]; then
    echo "retry: No arguments given" && return 1
  fi
  n=$1
  shift; #shift out nbr_retries
  results=()
  until [ $n -eq 0 ]
  do
     eval "$@"
     results+=("$?")
     [ $? -eq 0 ] || break
     n=$[$n-1]

    zeroes=0
    for i in ${results[@]}; do
       if [ $i -eq 0 ]; then
         zeroes=$(( zeroes + 1))
       fi
    done

    pct=$(($zeroes / ${#results[@]}))
    pct=$(($pct * 100))
    if [[ $zeroes -eq ${#results[@]} ]]; then
      out_color="\e[0;32m" # Light green
    else
      out_color="\e[0;31m" # Light red
    fi
    echo -e "$out_color\n\n"\
            "-------------------\n"\
            "Results: [${results[@]}]\n"\
            "Success rate: $pct% \n"\
            "-------------------\e[0m"
  done

  if [ $zeroes -eq ${#results[@]} ]; then
    return 0 # Success
  else
    return 1 # Failure
  fi
}


## Format code
cs(){
    case "$1" in
        style)
            echo "Formating source files..."
            # Modified kdelibs coding style as defined in
            #   http://techbase.kde.org/Policies/Kdelibs_Coding_Style

            find -regex ".*\.\(c\|cpp\|h\)" -exec \
                astyle --indent=spaces=4\
                  --indent-labels --pad-oper --unpad-paren --pad-header \
                  --keep-one-line-statements --convert-tabs \
                  --indent-preprocessor "{}" \;

            find -regex ".*\.\(java\)" -exec \
                astyle --mode=java --indent=spaces=4 \
                  --indent-labels --pad-oper --unpad-paren --pad-header \
                  --keep-one-line-statements --convert-tabs \
                  --indent-preprocessor "{}" \;

            # Other variants:
              # Maybe use --mode=java for java files, --mode=c

              # find . -perm -200 -regex ".*[.][CHch]p*" -exec astyle \
              #    --suffix=none --style=ansi --convert-tabs "{}" \;

              # find -regex ".*[.][CHch]p*" -exec astyle  --style=attach "{}" \;

              # astyle --indent=spaces=4 --brackets=break \
              #     --indent-labels --pad-oper --unpad-paren --pad-header \
              #     --keep-one-line-statements --convert-tabs \
              #     --indent-preprocessor \
              #     `find -type f -name '*.c'` \
              #     `find -type f -name '*.cpp'` \
              #     `find -type f -name '*.h'` \
              #     `find -type f -name '*.java'`

            # Apply coding conventions for Python code
            # http://www.python.org/dev/peps/pep-0008/
            # https://pypi.python.org/pypi/autopep8/
            # https://github.com/jcrocholl/pep8
            # sudo pip-python install --upgrade autopep8
            for file in $(find . -name "*.py")
            do
              #echo "Creating backup: $file.orig"
              #cp -v $file{,.orig}
              cp $file{,.orig}

              #echo "Formating file: $file"
              autopep8 -i "$file"

              diff "$file" "$file.orig" >> /dev/null  \
                && echo "Unchanged  $file" || echo "Formatted  $file"
            done
        ;;
        clean)
            echo "Deleting temporary files and backup copies..."
            #find . \( -name "*.orig" -or -name "*~" \) -exec rm -v "{}" \;
            #find -regex ".*\(orig\|~\|pyc\|bak\)" -delete
            find -regex ".*\(orig\|~\|pyc\|bak\)" -exec rm -v "{}" \;
        ;;
        *)
            echo "run 'cs style' to format all"\
                ".c .cpp .h .java and .py files recursively"

            echo "run 'cs clean' to delete temporary"\
                "files and backup copies (*.orig)"
        ;;
    esac
}

## Autotrace
atrace(){
  filename="${1%.*}"
  autotrace $1 -output-file "$filename.svg" -output-format svg --color-count 2
}

## Fix gcode for hacklab laser
fixlaser(){
  if [ -z ${2+x} ]; then
    SPEED=400
  else
    SPEED=$2
  fi
  sed -e "s/F400.000000/F${SPEED}.000000/g" -i $1

  # The spindle speed etc has to be set, or the laser will not turn on
  # Gcodetools inkscape plugin does not do this properly. 
  sed -i 's/^M3$/M3 S1 F500/' $1

  # Try to make sure that the laser is properly shut off before jogging
  sed -e 's/G01 Z-[0-9]\.[0-9]* F[0-9.]*/M62 P0/g' -e 's/G00 Z[0-9]\.[0-9]*/M63 P0/g' -e 's/Z-[0-9]\.[0-9]*/Z0.000000/g' -i $1
#  sed -e 's/G01 Z-[0-9]\.[0-9]* F100.0/M3 S1\nM62 P0/g' -e 's/G00 Z[0-9]\.[0-9]*/M5\nM63 P0/g' -e 's/Z-[0-9]\.[0-9]*/Z0.000000/g' -i $1

}

svgwidth(){
  filename="${1%.*}"
  rsvg-convert -a -w $2 -f svg $1 -o "${filename}_w${2}.svg"
}

function get_maintainer {
  NUM_COMMITS=$1

  if [ -z ${1+x} ]; then echo "Number of commits to send not set"; return; fi

  ROOT=$(git rev-parse --show-toplevel)
  if [ $? -ne 0 ]; then return; fi
  SCRIPT="$ROOT/scripts/get_maintainer.pl"
  if [ ! -f "$SCRIPT" ]; then echo "This is not a linux repository!" && return; fi

  MAINTAINERS=$(git format-patch HEAD~$NUM_COMMITS..HEAD --stdout | $SCRIPT)

  # Remove extraneous stats
  MAINTAINERS=$(echo "$MAINTAINERS" | sed 's/(.*//g')

  # Remove names from email addresses
  MAINTAINERS=$(echo "$MAINTAINERS" | sed 's/.*<//g')

  # Remove left over character
  MAINTAINERS=$(echo "$MAINTAINERS" | sed 's/>//g')

  echo "$MAINTAINERS" | while read email; do
    echo -n "--to=${email}  ";
  done
}

function checkpatch {
  ROOT=$(git rev-parse --show-toplevel)
  if [ $? -ne 0 ]; then return; fi
  SCRIPT="$ROOT/scripts/scripts/checkpatch.pl"
  if [ ! -f "$SCRIPT" ]; then echo "This is not a linux repository!" && return; fi

  if [ -z ${1+x} ]; then
    exec git diff | $SCRIPT --no-signoff -q -
  elif [[ $1 == *"cache"* ]]; then
    exec git diff --cached | $SCRIPT --no-signoff -q -
  else
    NUM_COMMITS=$1
    exec git diff HEAD~$NUM_COMMITS..HEAD | $SCRIPT --no-signoff -q -
  fi
}

function update_zimage {
  (cd && sudo cp zImage /boot/zImage && sync && rm zImage && sudo reboot)
}

function rpi_zimage {
  if [ -z ${1+x} ]; then echo "IP not set!"; return 1; fi
  (
    cd ~/work/linux/ && \
    scp arch/arm/boot/zImage $1:~/zImage && \
    ssh $1 "$(typeset -f update_zimage); update_zimage"
  )
}

function update_rpi {
  (
    cd ~/work/linux/ && \
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- && \
    rpi_zimage
  )
}

function concatenate_colon {
	local IFS=':'
	echo "$*"
}

function add_export_env {
	local VAR="$1"
	shift
	local VAL=$(eval echo "\$$VAR")
	if [ "$VAL" ]; then
		VAL=$(concatenate_colon "$@" "$VAL");
	else
		VAL=$(concatenate_colon "$@");
	fi
	eval "export $VAR=\"$VAL\""
}

function prefix_setup {
	local PFX="$1"

	add_export_env PATH "$PFX/bin"
	add_export_env LD_LIBRARY_PATH "$PFX/lib"
	add_export_env LIBGL_DRIVERS_PATH "$PFX/lib/dri"
	add_export_env PKG_CONFIG_PATH "$PFX/lib/pkgconfig/" "$PFX/share/pkgconfig/"
	add_export_env MANPATH "$PFX/share/man"
	export ACLOCAL_PATH="$PFX/share/aclocal"
	export ACLOCAL="aclocal -I $ACLOCAL_PATH"
}

function projectshell {

local PROJECTSHELL="$1"
local IGNORE_LATEX="*.log *.blg *.bbl *.aux *.brf *.tmp *.dvi *.toc *.out *.idx *.ilg *.ind"

case "$PROJECTSHELL" in
	latex)
		export CVSIGNORE="$IGNORE_LATEX"
		;;
	arch_i386)
		export ARCH=i386
		export KBUILD_OUTPUT=i386-objs/
		cd ~/linux-git
		;;
	wayland)
		export ALT_LOCAL="/opt/local"
		prefix_setup "$ALT_LOCAL"

		export MESA_DEBUG=1
		export EGL_LOG_LEVEL=debug
		export LIBGL_DEBUG=verbose
		#export WAYLAND_DEBUG=1

		export EGL_DRIVER=egl_dri2
		#export XDG_RUNTIME_DIR="$ALT_LOCAL/tmp"
		#export XDG_CONFIG_HOME="$ALT_LOCAL/etc"
		export TOYTOOLKIT_CURSOR_THEME=Vanilla-DMZ
		alias weston-x11="weston --width=800 --height=600"
		#cd ~/git/weston
		;;
	wayland-qt5)
		projectshell wayland
		export QTVER=qt5
		export QT_SOURCE_DIR="$HOME/android/git/qtbase"
		add_export_env PATH "$QT_SOURCE_DIR/bin"
		add_export_env LD_LIBRARY_PATH "$QT_SOURCE_DIR/lib"
		add_export_env PKG_CONFIG_PATH "$QT_SOURCE_DIR/lib/pkgconfig"
		export QT_PLUGIN_PATH="$QT_SOURCE_DIR/lib/plugins"
		cd ~/android/git/qtbase
		;;
	piglit)
		export ALT_LOCAL="/opt/local"
		prefix_setup "$ALT_LOCAL"
		export C_INCLUDE_PATH="$ALT_LOCAL/include"
		export LIBRARY_PATH="$ALT_LOCAL/lib"
		export PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1

		cd ~/git/piglit
		;;
	pixman)
		export PFX="$HOME/tmp/pixman-install"
		prefix_setup "$PFX"
		;;
	cairo-bench)
		cd ~/git/pixman-benchmarking
		source ./cairo-env-setup.bash
		;;
	eyepiece)
		export PFX="$HOME/tmp/eyepiece-install"
		prefix_setup "$PFX"
		mkdir -p "$PFX"
		cd ~/work/git/eyepiece
		;;
	rpi)
		RPITOOLS="$HOME/work/git/rpi-tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian"
		add_export_env PATH "$RPITOOLS/bin"
		;;
	int0059)
		export ANDROID_HOME="$HOME/work/android/adt-bundle-linux-x86_64-20140702/sdk"
		add_export_env PATH "$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
		cd ~/work/INT0059/xw-native-comparison
		;;
	chroot-lucid_i386)
		add_export_env PATH "$HOME/work/tpg/arm-2009q1/bin"
		cd ~/work/tpg
		source tpg-oe/arago/setenv
		;;
	home.git)
		export GIT_DIR="$HOME/git/home.git"
		export GIT_WORK_TREE="$HOME"
		;;
	*)
		echo "Warning: unknown projectshell '$PROJECTSHELL'."
		;;
esac

}

man() {
    env \
        LESS_TERMCAP_mb=$'\e[1;31m' \
        LESS_TERMCAP_md=$'\e[1;31m' \
        LESS_TERMCAP_me=$'\e[0m' \
        LESS_TERMCAP_se=$'\e[0m' \
        LESS_TERMCAP_so=$'\e[1;44;33m' \
        LESS_TERMCAP_ue=$'\e[0m' \
        LESS_TERMCAP_us=$'\e[1;32m' \
            man "$@"
}
