# FreeAgent puts the powerline style in zsh !

#Two-line version modified by brucehsu
#Some code borrowed from Phil's Prompt and bira theme
#http://aperiodic.net/phil/prompt/

# Dim version modified by Howar31

# Remodified by Kf4btg to be not so dim, to
# fix the unicode for the powerline glyphs, and to
# probably only work in konsole now.

# NOTE: I found that using antialiasing messes
# with the powerline glyphs of some fonts, mostly
# causing them to not line up properly, resulting in
# gaps and off-color lines between the segments.
# Setting the glyphs to use bold weight helped to
# get rid of the gaps in my case; though this caused
# a couple other visual glitches, these are less
# aesthetically jarring in my opinion. I am pleased.
# #################################################

# Color settings
# DIR_BG=%K{233}
DIR_BG=%K{234}
# DIR_FG=%F{24}
# DIR_FG=%F{109}
DIR_FG=%F{174}

# GIT_BG=%K{233}
GIT_BG=%K{234}
GIT_FG=%F{239}

# FILL_BG=%K{233}
# FILL_FG=%{$fg[white]%}
# TIME_BG=%K{239}
TIME_BG=%K{65}
# TIME_FG=%F{251}
TIME_FG=%F{233}
# DATE_BG=%K{245}
DATE_BG=%K{109}
DATE_FG=%F{233}
# USER_BG=%K{24}
USER_BG=%K{109}
USER_FG=%F{232}
HOST_BG=%K{233}
HOST_FG=%F{239}


# GIT_DIRTY_COLOR=%F{124}
GIT_DIRTY_COLOR=%F{167}
# GIT_CLEAN_COLOR=%F{118}
GIT_CLEAN_COLOR=%F{108}
GIT_PROMPT_INFO=%F{012}

ERROR_FG=%F{232}
ERROR_BG=%K{167}

# explicitly set the RGB values for the ERROR_BG color;
# will only work on terminals which support 24-bit color-depth
# (truecolor; on Linux, apparently only xterm & konsole)
# ERROR_BG=$'%{x1b[48;2;196;55;53m%}'

# Seems that the only way to get the foreground
# color to match the background both in color AND
# translucency on konsole is to *explicitly* use
# the R, G, & B values that are set for the background
# in konsole's current colorscheme file, thus tricking
# it into applying the translucency effect.
# They can be manually copied from the scheme file,
# or one could possibly write
# some ugly abomination to parse them.
# TRANS_FG=$'%{\x1b[38;2;35;38;41m%}'
# TRANS_FG="\e[38;2;35;38;41m"

# ...it would probably be easier to patch
# the font to include the inverted glyph...


# reset color
reset_color=%f%k%b
RESET=%{$reset_color%}

PL_PROMPT_RSEP=$'\ue0b0'
PL_PROMPT_RSEP_THIN=$'\ue0b1'
PL_PROMPT_LSEP=$'\ue0b2'
PL_PROMPT_LSEP_THIN=$'\ue0b3'

ZSH_THEME_GIT_PROMPT_PREFIX=" \ue0a0 "
ZSH_THEME_GIT_PROMPT_SUFFIX="$GIT_PROMPT_INFO"
ZSH_THEME_GIT_PROMPT_DIRTY=" $GIT_DIRTY_COLOR✘ "
ZSH_THEME_GIT_PROMPT_CLEAN=" $GIT_CLEAN_COLOR✔ "

ZSH_THEME_GIT_PROMPT_ADDED="%F{082}✚%f"
ZSH_THEME_GIT_PROMPT_MODIFIED="%F{166}✹%f"
ZSH_THEME_GIT_PROMPT_DELETED="%F{160}✖%f"
ZSH_THEME_GIT_PROMPT_RENAMED="%F{220]➜%f"
ZSH_THEME_GIT_PROMPT_UNMERGED="%F{082]═%f"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%F{190]✭%f"


function __git_brief() {

	[ -d .git ] && print "$GIT_BG$GIT_FG$(git_prompt_info)$GIT_BG$GIT_FG$RESET" && return
	print ""


    # local ref=$(git symbolic-ref HEAD 2> /dev/null)
	# if [[ -n "$ref" ]]; then
		# print "${ZSH_THEME_GIT_PROMPT_PREFIX} ${ref#refs/heads/}"
	# else
		# print ""
	# fi
}

function get_git_branch() {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return 0
    ref=${ref#refs/heads/}
    echo "$ref       "
}

function __truncate_path {

	local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 1 ))

	local plcwd="$(echo ${${PWD/#$HOME/ ~}:1} | sed 's`\([^\]\?\)/`\1 '$PL_PROMPT_RSEP_THIN' `g')"
    PL_DIR="$DIR_BG$DIR_FG $plcwd $RESET$pl_dir_endcap"
	local pwdsize=${#${(%e)PL_DIR}}

	if [[ $pwdsize -gt $TERMWIDTH ]]; then
		pwdsize=$TERMWIDTH
		print "$DIR_BG$DIR_FG%$pwdsize<...<$PL_DIR%<<"
	else
		print "$PL_DIR"
	fi
}

# new prompt outline:
# [info.dir]>
# [user]>[info.git]>[return]> ... <[time]<[date]

prompt_newline=$'\n%{\r%}'

# pl_dir="$DIR_BG$DIR_FG %~ $RESET${DIR_BG/K/F}%B$PL_PROMPT_RSEP$RESET"
pl_dir=$'$(__truncate_path)'

# pl_git_branch="$GIT_BG$GIT_FG"$'`git_prompt_info`'"$GIT_BG$GIT_FG$RESET"
pl_git_branch="$GIT_BG$GIT_FG"$'`__git_brief`'"$GIT_BG$GIT_FG$RESET"
# pl_git_branch="$GIT_BG$GIT_FG master $GIT_BG$GIT_FG$RESET"

pl_time="$TIME_BG $TIME_FG%t ${DATE_BG/K/F}%B${PL_PROMPT_LSEP}$RESET$DATE_BG$DATE_FG %D{%Y-%m-%d} $RESET"
# pl_time="$TIME_BG $TIME_FG%t ${GIT_BG/K/F}${PL_PROMPT_LSEP_THIN}${DATE_BG/K/F}%B${PL_PROMPT_LSEP}$RESET$DATE_BG$DATE_FG %D{%Y-%m-%d} $RESET"
# pl_time="$TIME_BG $TIME_FG%t ${GIT_BG/K/F}%B${PL_PROMPT_LSEP}${GIT_BG}${DATE_BG/K/F}%B${PL_PROMPT_LSEP}$RESET$DATE_BG$DATE_FG %D{%Y-%m-%d} $RESET"

pl_user="$USER_BG$USER_FG %n $RESET${USER_BG/K/F}$GIT_BG%B$PL_PROMPT_RSEP" #$PL_PROMPT_RSEP_THIN$RESET"
#pl_host="%K{$HOST_BG}%F{$HOST_FG} @%m %k%f%F{$HOST_BG}"$'\ue0b0'"%f%k"


pl_status_good="${GIT_BG/K/F}$USER_BG%B$PL_PROMPT_RSEP$RESET${USER_BG/K/F}%B$PL_PROMPT_RSEP$RESET"

pl_status_bad="${GIT_BG/K/F}$ERROR_BG%B$PL_PROMPT_RSEP$ERROR_FG$ERROR_BG %? $RESET${ERROR_BG/K/F}%B$PL_PROMPT_RSEP$RESET"


## the entire 2nd line:
#    user > [git branch] > [return code]
# the main foreground color of the line will change to red
# when the previous command has a non-zero status
pl_user_git_status="\
%(?.\
%B$USER_BG$USER_FG %n $RESET\
${USER_BG/K/F}$GIT_BG%B$PL_PROMPT_RSEP$RESET\
${pl_git_branch}\
${pl_status_good}\
.\
%B$ERROR_BG$USER_FG %n $RESET\
${ERROR_BG/K/F}$GIT_BG%B$PL_PROMPT_RSEP$RESET\
${pl_git_branch}\
${pl_status_bad}\
)"

# pl_status="%(?.${pl_status_good}.${pl_status_bad})"

pl_right_time="${TIME_BG/K/F}%B${PL_PROMPT_LSEP}$RESET$pl_time"

pl_dir_endcap="${DIR_BG/K/F}%B$PL_PROMPT_RSEP$RESET"

function precmd {

    ## recalculate the fill size (padding btwn L & R
    ## parts of the first line) each time in case of terminal resize
    # local plcwd="${${PWD/#$HOME/ ~}:1}"
    # plcwd="${plcwd//// ${PL_PROMPT_RSEP_THIN} }"
    # local PL_DIR=""
    # PL_DIR="$DIR_BG$DIR_FG $plcwd $RESET"
    # PL_DIR="$DIR_BG$DIR_FG $plcwd $RESET$pl_dir_endcap"

    # local padsize=$(( COLUMNS - ${#${(%e)plcwd}} - 26 ))
	# local PL_FILL=""

	## using the "medium shade" as the fill character allows for a nice subtle
    ## visual connection between the R&L sides of the prompt that is slightly
    ## darker than the background while simultaneously retaining some translucency.
	# eval "PL_FILL=${(l.${padsize}..▒.)}"
# 	eval "PL_FILL=\${(l.${padsize}..━.)}"

	# PROMPT="$prompt_newline$PL_DIR$pl_fill_pre$PL_FILL$pl_fill_post$pl_time$prompt_newline${pl_user_git_status} "
	# PROMPT="$prompt_newline$PL_DIR$prompt_newline${pl_user_git_status} "
	PROMPT="$prompt_newline$pl_dir$prompt_newline${pl_user_git_status} "
	RPROMPT="$pl_right_time"
	#${pl_user}${pl_git_branch}${pl_status} "
}

# kate::syntax zsh
