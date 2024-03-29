#   bash_completion - programmable completion functions for bash 3.2+
#
#   Copyright © 2006-2008, Ian Macdonald <ian@caliban.org>
#             © 2009-2011, Bash Completion Maintainers
#                     <bash-completion-devel@lists.alioth.debian.org>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2, or (at your option)
#   any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software Foundation,
#   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
#   The latest version of this software can be obtained here:
#
#   http://bash-completion.alioth.debian.org/
#
#   RELEASE: 1.3

if [[ $- == *v* ]]; then
    BASH_COMPLETION_ORIGINAL_V_VALUE="-v"
else
    BASH_COMPLETION_ORIGINAL_V_VALUE="+v"
fi

if [[ -n $BASH_COMPLETION_DEBUG ]]; then
    set -v
else
    set +v
fi

# Alter the following to reflect the location of this file.
#
[ -n "$BASH_COMPLETION" ] || BASH_COMPLETION=/usr/local/etc/bash_completion
[ -n "$BASH_COMPLETION_DIR" ] || BASH_COMPLETION_DIR=/usr/local/etc/bash_completion.d
[ -n "$BASH_COMPLETION_COMPAT_DIR" ] || BASH_COMPLETION_COMPAT_DIR=/usr/local/etc/bash_completion.d
readonly BASH_COMPLETION BASH_COMPLETION_DIR BASH_COMPLETION_COMPAT_DIR

# Set a couple of useful vars
#
UNAME=$( uname -s )
# strip OS type and version under Cygwin (e.g. CYGWIN_NT-5.1 => Cygwin)
UNAME=${UNAME/CYGWIN_*/Cygwin}

case ${UNAME} in
    Linux|GNU|GNU/*) USERLAND=GNU ;;
    *) USERLAND=${UNAME} ;;
esac

# Turn on extended globbing and programmable completion
shopt -s extglob progcomp

# A lot of the following one-liners were taken directly from the
# completion examples provided with the bash 2.04 source distribution

# Make directory commands see only directories
complete -d pushd

# The following section lists completions that are redefined later
# Do NOT break these over multiple lines.
#
# START exclude -- do NOT remove this line
# bzcmp, bzdiff, bz*grep, bzless, bzmore intentionally not here, see Debian: #455510
complete -f -X '!*.?(t)bz?(2)' bunzip2 bzcat pbunzip2 pbzcat
complete -f -X '!*.@(zip|[ejw]ar|exe|pk3|wsz|zargo|xpi|sxw|o[tx]t|od[fgpst]|epub|apk)' unzip zipinfo
complete -f -X '*.Z' compress znew
# zcmp, zdiff, z*grep, zless, zmore intentionally not here, see Debian: #455510
complete -f -X '!*.@(Z|[gGd]z|t[ag]z)' gunzip zcat unpigz
complete -f -X '!*.Z' uncompress
# lzcmp, lzdiff intentionally not here, see Debian: #455510
complete -f -X '!*.@(tlz|lzma)' lzcat lzegrep lzfgrep lzgrep lzless lzmore unlzma
complete -f -X '!*.@(?(t)xz|tlz|lzma)' unxz xzcat
complete -f -X '!*.lrz' lrunzip
complete -f -X '!*.@(gif|jp?(e)g|miff|tif?(f)|pn[gm]|p[bgp]m|bmp|xpm|ico|xwd|tga|pcx)' ee
complete -f -X '!*.@(gif|jp?(e)g|tif?(f)|png|p[bgp]m|bmp|x[bp]m|rle|rgb|pcx|fits|pm)' xv qiv
complete -f -X '!*.@(@(?(e)ps|?(E)PS|pdf|PDF)?(.gz|.GZ|.bz2|.BZ2|.Z))' gv ggv kghostview
complete -f -X '!*.@(dvi|DVI)?(.@(gz|Z|bz2))' xdvi kdvi
complete -f -X '!*.dvi' dvips dviselect dvitype dvipdf advi dvipdfm dvipdfmx
complete -f -X '!*.[pf]df' acroread gpdf xpdf
complete -f -X '!*.@(?(e)ps|pdf)' kpdf
complete -f -X '!*.@(@(?(e)ps|?(E)PS|[pf]df|[PF]DF|dvi|DVI)?(.gz|.GZ|.bz2|.BZ2)|cb[rz]|djv?(u)|gif|jp?(e)g|miff|tif?(f)|pn[gm]|p[bgp]m|bmp|xpm|ico|xwd|tga|pcx|fdf)' evince
complete -f -X '!*.@(okular|@(?(e|x)ps|?(E|X)PS|pdf|PDF|dvi|DVI|cb[rz]|CB[RZ]|djv?(u)|DJV?(U)|dvi|DVI|gif|jp?(e)g|miff|tif?(f)|pn[gm]|p[bgp]m|bmp|xpm|ico|xwd|tga|pcx|GIF|JP?(E)G|MIFF|TIF?(F)|PN[GM]|P[BGP]M|BMP|XPM|ICO|XWD|TGA|PCX|epub|EPUB|odt|ODT|fb?(2)|FB?(2)|mobi|MOBI|g3|G3|chm|CHM|fdf|FDF)?(.?(gz|GZ|bz2|BZ2)))' okular
complete -f -X '!*.@(?(e)ps|pdf)' ps2pdf ps2pdf12 ps2pdf13 ps2pdf14 ps2pdfwr
complete -f -X '!*.texi*' makeinfo texi2html
complete -f -X '!*.@(?(la)tex|texi|dtx|ins|ltx)' tex latex slitex jadetex pdfjadetex pdftex pdflatex texi2dvi
complete -f -X '!*.mp3' mpg123 mpg321 madplay
complete -f -X '!*@(.@(mp?(e)g|MP?(E)G|wma|avi|AVI|asf|vob|VOB|bin|dat|divx|DIVX|vcd|ps|pes|fli|flv|FLV|fxm|FXM|viv|rm|ram|yuv|mov|MOV|qt|QT|wmv|mp[234]|MP[234]|m4[pv]|M4[PV]|mkv|MKV|og[gmv]|OG[GMV]|t[ps]|T[PS]|m2t?(s)|M2T?(S)|wav|WAV|flac|FLAC|asx|ASX|mng|MNG|srt|m[eo]d|M[EO]D|s[3t]m|S[3T]M|it|IT|xm|XM)|+([0-9]).@(vdr|VDR))?(.part)' xine aaxine fbxine
complete -f -X '!*@(.@(mp?(e)g|MP?(E)G|wma|avi|AVI|asf|vob|VOB|bin|dat|divx|DIVX|vcd|ps|pes|fli|flv|FLV|fxm|FXM|viv|rm|ram|yuv|mov|MOV|qt|QT|wmv|mp[234]|MP[234]|m4[pv]|M4[PV]|mkv|MKV|og[gmv]|OG[GMV]|t[ps]|T[PS]|m2t?(s)|M2T?(S)|wav|WAV|flac|FLAC|asx|ASX|mng|MNG|srt|m[eo]d|M[EO]D|s[3t]m|S[3T]M|it|IT|xm|XM|iso|ISO)|+([0-9]).@(vdr|VDR))?(.part)' kaffeine dragon
complete -f -X '!*.@(avi|asf|wmv)' aviplay
complete -f -X '!*.@(rm?(j)|ra?(m)|smi?(l))' realplay
complete -f -X '!*.@(mpg|mpeg|avi|mov|qt)' xanim
complete -f -X '!*.@(ogg|m3u|flac|spx)' ogg123
complete -f -X '!*.@(mp3|ogg|pls|m3u)' gqmpeg freeamp
complete -f -X '!*.fig' xfig
complete -f -X '!*.@(mid?(i)|cmf)' playmidi
complete -f -X '!*.@(mid?(i)|rmi|rcp|[gr]36|g18|mod|xm|it|x3m|s[3t]m|kar)' timidity
complete -f -X '!*.@(m[eo]d|s[3t]m|xm|it)' modplugplay modplug123
complete -f -X '*.@(o|so|so.!(conf)|a|[rs]pm|gif|jp?(e)g|mp3|mp?(e)g|avi|asf|ogg|class)' vi vim gvim rvim view rview rgvim rgview gview emacs xemacs sxemacs kate kwrite
complete -f -X '!*.@([eE][xX][eE]?(.[sS][oO])|[cC][oO][mM]|[sS][cC][rR])' wine
complete -f -X '!*.@(zip|z|gz|tgz)' bzme
# konqueror not here on purpose, it's more than a web/html browser
complete -f -X '!*.@(?([xX]|[sS])[hH][tT][mM]?([lL]))' netscape mozilla lynx opera galeon dillo elinks amaya firefox mozilla-firefox iceweasel google-chrome chromium-browser epiphany
complete -f -X '!*.@(sxw|stw|sxg|sgl|doc?([mx])|dot?([mx])|rtf|txt|htm|html|odt|ott|odm)' oowriter
complete -f -X '!*.@(sxi|sti|pps?(x)|ppt?([mx])|pot?([mx])|odp|otp)' ooimpress
complete -f -X '!*.@(sxc|stc|xls?([bmx])|xlw|xlt?([mx])|[ct]sv|ods|ots)' oocalc
complete -f -X '!*.@(sxd|std|sda|sdd|odg|otg)' oodraw
complete -f -X '!*.@(sxm|smf|mml|odf)' oomath
complete -f -X '!*.odb' oobase
complete -f -X '!*.[rs]pm' rpm2cpio
complete -f -X '!*.aux' bibtex
complete -f -X '!*.po' poedit gtranslator kbabel lokalize
complete -f -X '!*.@([Pp][Rr][Gg]|[Cc][Ll][Pp])' harbour gharbour hbpp
complete -f -X '!*.[Hh][Rr][Bb]' hbrun
complete -f -X '!*.ly' lilypond ly2dvi
complete -f -X '!*.@(dif?(f)|?(d)patch)?(.@([gx]z|bz2|lzma))' cdiff
complete -f -X '!*.lyx' lyx
complete -f -X '!@(*.@(ks|jks|jceks|p12|pfx|bks|ubr|gkr|cer|crt|cert|p7b|pkipath|pem|p10|csr|crl)|cacerts)' portecle
complete -f -X '!*.@(mp[234c]|og[ag]|@(fl|a)ac|m4[abp]|spx|tta|w?(a)v|wma|aif?(f)|asf|ape)' kid3 kid3-qt
# FINISH exclude -- do not remove this line

# start of section containing compspecs that can be handled within bash

# user commands see only users
complete -u su write chfn groups slay w sux runuser

# bg completes with stopped jobs
complete -A stopped -P '"%' -S '"' bg

# other job commands
complete -j -P '"%' -S '"' fg jobs disown

# readonly and unset complete with shell variables
complete -v readonly unset

# set completes with set options
complete -A setopt set

# shopt completes with shopt options
complete -A shopt shopt

# helptopics
complete -A helptopic help

# unalias completes with aliases
complete -a unalias

# bind completes with readline bindings (make this more intelligent)
complete -A binding bind

# type and which complete on commands
complete -c command type which

# builtin completes on builtins
complete -b builtin

# start of section containing completion functions called by other functions

# This function checks whether we have a given program on the system.
# No need for bulky functions in memory if we don't.
#
have()
{
    unset -v have
    # Completions for system administrator commands are installed as well in
    # case completion is attempted via `sudo command ...'.
    PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin type $1 &>/dev/null &&
    have="yes"
}

# This function checks whether a given readline variable
# is `on'.
#
_rl_enabled()
{
    [[ "$( bind -v )" = *$1+([[:space:]])on* ]]
}

# This function shell-quotes the argument
quote()
{
    echo \'${1//\'/\'\\\'\'}\' #'# Help vim syntax highlighting
}

# @see _quote_readline_by_ref()
quote_readline()
{
    local quoted
    _quote_readline_by_ref "$1" ret
    printf %s "$ret"
} # quote_readline()


# This function shell-dequotes the argument
dequote()
{
    eval echo "$1" 2> /dev/null
}


# Assign variable one scope above the caller
# Usage: local "$1" && _upvar $1 "value(s)"
# Param: $1  Variable name to assign value to
# Param: $*  Value(s) to assign.  If multiple values, an array is
#            assigned, otherwise a single value is assigned.
# NOTE: For assigning multiple variables, use '_upvars'.  Do NOT
#       use multiple '_upvar' calls, since one '_upvar' call might
#       reassign a variable to be used by another '_upvar' call.
# See: http://fvue.nl/wiki/Bash:_Passing_variables_by_reference
_upvar() {
    if unset -v "$1"; then           # Unset & validate varname
        if (( $# == 2 )); then
            eval $1=\"\$2\"          # Return single value
        else
            eval $1=\(\"\${@:2}\"\)  # Return array
        fi
    fi
}


# Assign variables one scope above the caller
# Usage: local varname [varname ...] && 
#        _upvars [-v varname value] | [-aN varname [value ...]] ...
# Available OPTIONS:
#     -aN  Assign next N values to varname as array
#     -v   Assign single value to varname
# Return: 1 if error occurs
# See: http://fvue.nl/wiki/Bash:_Passing_variables_by_reference
_upvars() {
    if ! (( $# )); then
        echo "${FUNCNAME[0]}: usage: ${FUNCNAME[0]} [-v varname"\
            "value] | [-aN varname [value ...]] ..." 1>&2
        return 2
    fi
    while (( $# )); do
        case $1 in
            -a*)
                # Error checking
                [[ ${1#-a} ]] || { echo "bash: ${FUNCNAME[0]}: \`$1': missing"\
                    "number specifier" 1>&2; return 1; }
                printf %d "${1#-a}" &> /dev/null || { echo "bash:"\
                    "${FUNCNAME[0]}: \`$1': invalid number specifier" 1>&2
                    return 1; }
                # Assign array of -aN elements
                [[ "$2" ]] && unset -v "$2" && eval $2=\(\"\${@:3:${1#-a}}\"\) && 
                shift $((${1#-a} + 2)) || { echo "bash: ${FUNCNAME[0]}:"\
                    "\`$1${2+ }$2': missing argument(s)" 1>&2; return 1; }
                ;;
            -v)
                # Assign single value
                [[ "$2" ]] && unset -v "$2" && eval $2=\"\$3\" &&
                shift 3 || { echo "bash: ${FUNCNAME[0]}: $1: missing"\
                "argument(s)" 1>&2; return 1; }
                ;;
            *)
                echo "bash: ${FUNCNAME[0]}: $1: invalid option" 1>&2
                return 1 ;;
        esac
    done
}


# Reassemble command line words, excluding specified characters from the
# list of word completion separators (COMP_WORDBREAKS).
# @param $1 chars  Characters out of $COMP_WORDBREAKS which should
#     NOT be considered word breaks. This is useful for things like scp where
#     we want to return host:path and not only path, so we would pass the
#     colon (:) as $1 here.
# @param $2 words  Name of variable to return words to
# @param $3 cword  Name of variable to return cword to
#
__reassemble_comp_words_by_ref() {
    local exclude i j ref
    # Exclude word separator characters?
    if [[ $1 ]]; then
        # Yes, exclude word separator characters;
        # Exclude only those characters, which were really included
        exclude="${1//[^$COMP_WORDBREAKS]}"
    fi
        
    # Default to cword unchanged
    eval $3=$COMP_CWORD
    # Are characters excluded which were former included?
    if [[ $exclude ]]; then
        # Yes, list of word completion separators has shrunk;
        # Re-assemble words to complete
        for (( i=0, j=0; i < ${#COMP_WORDS[@]}; i++, j++)); do
            # Is current word not word 0 (the command itself) and is word not
            # empty and is word made up of just word separator characters to be
            # excluded?
            while [[ $i -gt 0 && ${COMP_WORDS[$i]} && 
                ${COMP_WORDS[$i]//[^$exclude]} == ${COMP_WORDS[$i]} 
            ]]; do
                [ $j -ge 2 ] && ((j--))
                # Append word separator to current word
                ref="$2[$j]"
                eval $2[$j]=\${!ref}\${COMP_WORDS[i]}
                # Indicate new cword
                [ $i = $COMP_CWORD ] && eval $3=$j
                # Indicate next word if available, else end *both* while and for loop
                (( $i < ${#COMP_WORDS[@]} - 1)) && ((i++)) || break 2
            done
            # Append word to current word
            ref="$2[$j]"
            eval $2[$j]=\${!ref}\${COMP_WORDS[i]}
            # Indicate new cword
            [[ $i == $COMP_CWORD ]] && eval $3=$j
        done
    else
        # No, list of word completions separators hasn't changed;
        eval $2=\( \"\${COMP_WORDS[@]}\" \)
    fi
} # __reassemble_comp_words_by_ref()


# @param $1 exclude  Characters out of $COMP_WORDBREAKS which should NOT be
#     considered word breaks. This is useful for things like scp where
#     we want to return host:path and not only path, so we would pass the
#     colon (:) as $1 in this case.  Bash-3 doesn't do word splitting, so this
#     ensures we get the same word on both bash-3 and bash-4.
# @param $2 words  Name of variable to return words to
# @param $3 cword  Name of variable to return cword to
# @param $4 cur  Name of variable to return current word to complete to
# @see ___get_cword_at_cursor_by_ref()
__get_cword_at_cursor_by_ref() {
    local cword words=()
    __reassemble_comp_words_by_ref "$1" words cword

    local i cur2
    local cur="$COMP_LINE"
    local index="$COMP_POINT"
    for (( i = 0; i <= cword; ++i )); do
        while [[
            # Current word fits in $cur?
            "${#cur}" -ge ${#words[i]} &&
            # $cur doesn't match cword?
            "${cur:0:${#words[i]}}" != "${words[i]}"
        ]]; do
            # Strip first character
            cur="${cur:1}"
            # Decrease cursor position
            ((index--))
        done

        # Does found word matches cword?
        if [[ "$i" -lt "$cword" ]]; then
            # No, cword lies further;
            local old_size="${#cur}"
            cur="${cur#${words[i]}}"
            local new_size="${#cur}"
            index=$(( index - old_size + new_size ))
        fi
    done

    if [[ "${words[cword]:0:${#cur}}" != "$cur" ]]; then
        # We messed up. At least return the whole word so things keep working
        cur2=${words[cword]}
    else
        cur2=${cur:0:$index}
    fi

    local "$2" "$3" "$4" && 
        _upvars -a${#words[@]} $2 "${words[@]}" -v $3 "$cword" -v $4 "$cur2"
}


# Get the word to complete and optional previous words.
# This is nicer than ${COMP_WORDS[$COMP_CWORD]}, since it handles cases
# where the user is completing in the middle of a word.
# (For example, if the line is "ls foobar",
# and the cursor is here -------->   ^
# Also one is able to cross over possible wordbreak characters.
# Usage: _get_comp_words_by_ref [OPTIONS] [VARNAMES]
# Available VARNAMES:
#     cur         Return cur via $cur
#     prev        Return prev via $prev
#     words       Return words via $words
#     cword       Return cword via $cword
#
# Available OPTIONS:
#     -n EXCLUDE  Characters out of $COMP_WORDBREAKS which should NOT be 
#                 considered word breaks. This is useful for things like scp
#                 where we want to return host:path and not only path, so we
#                 would pass the colon (:) as -n option in this case.  Bash-3
#                 doesn't do word splitting, so this ensures we get the same
#                 word on both bash-3 and bash-4.
#     -c VARNAME  Return cur via $VARNAME
#     -p VARNAME  Return prev via $VARNAME
#     -w VARNAME  Return words via $VARNAME
#     -i VARNAME  Return cword via $VARNAME
#
# Example usage:
#
#    $ _get_comp_words_by_ref -n : cur prev
#
_get_comp_words_by_ref()
{
    local exclude flag i OPTIND=1
    local cur cword words=()
    local upargs=() upvars=() vcur vcword vprev vwords

    while getopts "c:i:n:p:w:" flag "$@"; do
        case $flag in
            c) vcur=$OPTARG ;;
            i) vcword=$OPTARG ;;
            n) exclude=$OPTARG ;;
            p) vprev=$OPTARG ;;
            w) vwords=$OPTARG ;;
        esac
    done
    while [[ $# -ge $OPTIND ]]; do 
        case ${!OPTIND} in
            cur)   vcur=cur ;;
            prev)  vprev=prev ;;
            cword) vcword=cword ;;
            words) vwords=words ;;
            *) echo "bash: $FUNCNAME(): \`${!OPTIND}': unknown argument" \
                1>&2; return 1 ;;
        esac
        let "OPTIND += 1"
    done

    __get_cword_at_cursor_by_ref "$exclude" words cword cur

    [[ $vcur   ]] && { upvars+=("$vcur"  ); upargs+=(-v $vcur   "$cur"  ); }
    [[ $vcword ]] && { upvars+=("$vcword"); upargs+=(-v $vcword "$cword"); }
    [[ $vprev  ]] && { upvars+=("$vprev" ); upargs+=(-v $vprev 
        "${words[cword - 1]}"); }
    [[ $vwords ]] && { upvars+=("$vwords"); upargs+=(-a${#words[@]} $vwords
        "${words[@]}"); }

    (( ${#upvars[@]} )) && local "${upvars[@]}" && _upvars "${upargs[@]}"
}


# Get the word to complete.
# This is nicer than ${COMP_WORDS[$COMP_CWORD]}, since it handles cases
# where the user is completing in the middle of a word.
# (For example, if the line is "ls foobar",
# and the cursor is here -------->   ^
# @param $1 string  Characters out of $COMP_WORDBREAKS which should NOT be
#     considered word breaks. This is useful for things like scp where
#     we want to return host:path and not only path, so we would pass the
#     colon (:) as $1 in this case.  Bash-3 doesn't do word splitting, so this
#     ensures we get the same word on both bash-3 and bash-4.
# @param $2 integer  Index number of word to return, negatively offset to the
#     current word (default is 0, previous is 1), respecting the exclusions
#     given at $1.  For example, `_get_cword "=:" 1' returns the word left of
#     the current word, respecting the exclusions "=:".
# @deprecated  Use `_get_comp_words_by_ref cur' instead
# @see _get_comp_words_by_ref()
_get_cword()
{
    local LC_CTYPE=C
    local cword words
    __reassemble_comp_words_by_ref "$1" words cword

    # return previous word offset by $2
    if [[ ${2//[^0-9]/} ]]; then
        printf "%s" "${words[cword-$2]}"
    elif [[ "${#words[cword]}" -eq 0 || "$COMP_POINT" == "${#COMP_LINE}" ]]; then
        printf "%s" "${words[cword]}"
    else
        local i
        local cur="$COMP_LINE"
        local index="$COMP_POINT"
        for (( i = 0; i <= cword; ++i )); do
            while [[
                # Current word fits in $cur?
                "${#cur}" -ge ${#words[i]} &&
                # $cur doesn't match cword?
                "${cur:0:${#words[i]}}" != "${words[i]}"
            ]]; do
                # Strip first character
                cur="${cur:1}"
                # Decrease cursor position
                ((index--))
            done

            # Does found word matches cword?
            if [[ "$i" -lt "$cword" ]]; then
                # No, cword lies further;
                local old_size="${#cur}"
                cur="${cur#${words[i]}}"
                local new_size="${#cur}"
                index=$(( index - old_size + new_size ))
            fi
        done

        if [[ "${words[cword]:0:${#cur}}" != "$cur" ]]; then
            # We messed up! At least return the whole word so things
            # keep working
            printf "%s" "${words[cword]}"
        else
            printf "%s" "${cur:0:$index}"
        fi
    fi
} # _get_cword()


# Get word previous to the current word.
# This is a good alternative to `prev=${COMP_WORDS[COMP_CWORD-1]}' because bash4
# will properly return the previous word with respect to any given exclusions to
# COMP_WORDBREAKS.
# @deprecated  Use `_get_comp_words_by_ref cur prev' instead
# @see _get_comp_words_by_ref()
#
_get_pword() 
{
    if [ $COMP_CWORD -ge 1 ]; then
        _get_cword "${@:-}" 1;
    fi
}


# If the word-to-complete contains a colon (:), left-trim COMPREPLY items with
# word-to-complete.
# On bash-3, and bash-4 with a colon in COMP_WORDBREAKS, words containing
# colons are always completed as entire words if the word to complete contains
# a colon.  This function fixes this, by removing the colon-containing-prefix
# from COMPREPLY items.
# The preferred solution is to remove the colon (:) from COMP_WORDBREAKS in
# your .bashrc:
#
#    # Remove colon (:) from list of word completion separators
#    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
#
# See also: Bash FAQ - E13) Why does filename completion misbehave if a colon
# appears in the filename? - http://tiswww.case.edu/php/chet/bash/FAQ
# @param $1 current word to complete (cur)
# @modifies global array $COMPREPLY
#
__ltrim_colon_completions() {
    # If word-to-complete contains a colon,
    # and bash-version < 4,
    # or bash-version >= 4 and COMP_WORDBREAKS contains a colon
    if [[
        "$1" == *:* && (
            ${BASH_VERSINFO[0]} -lt 4 || 
            (${BASH_VERSINFO[0]} -ge 4 && "$COMP_WORDBREAKS" == *:*) 
        )
    ]]; then
        # Remove colon-word prefix from COMPREPLY items
        local colon_word=${1%${1##*:}}
        local i=${#COMPREPLY[*]}
        while [ $((--i)) -ge 0 ]; do
            COMPREPLY[$i]=${COMPREPLY[$i]#"$colon_word"}
        done
    fi
} # __ltrim_colon_completions()


# This function quotes the argument in a way so that readline dequoting
# results in the original argument.  This is necessary for at least
# `compgen' which requires its arguments quoted/escaped:
#
#     $ ls "a'b/"
#     c
#     $ compgen -f "a'b/"       # Wrong, doesn't return output
#     $ compgen -f "a\'b/"      # Good (bash-4)
#     a\'b/c
#     $ compgen -f "a\\\\\'b/"  # Good (bash-3)
#     a\'b/c
#
# On bash-3, special characters need to be escaped extra.  This is
# unless the first character is a single quote (').  If the single
# quote appears further down the string, bash default completion also
# fails, e.g.:
#
#     $ ls 'a&b/'
#     f
#     $ foo 'a&b/<TAB>  # Becomes: foo 'a&b/f'
#     $ foo a'&b/<TAB>  # Nothing happens
#
# See also:
# - http://lists.gnu.org/archive/html/bug-bash/2009-03/msg00155.html
# - http://www.mail-archive.com/bash-completion-devel@lists.alioth.\
#   debian.org/msg01944.html
# @param $1  Argument to quote
# @param $2  Name of variable to return result to
_quote_readline_by_ref()
{
    if [[ ${1:0:1} == "'" ]]; then
        if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
            # Leave out first character
            printf -v $2 %s "${1:1}"
        else
            # Quote word, leaving out first character
            printf -v $2 %q "${1:1}"
            # Double-quote word (bash-3)
            printf -v $2 %q ${!2}
        fi
    elif [[ ${BASH_VERSINFO[0]} -le 3 && ${1:0:1} == '"' ]]; then
        printf -v $2 %q "${1:1}"
    else
        printf -v $2 %q "$1"
    fi

    # If result becomes quoted like this: $'string', re-evaluate in order to
    # drop the additional quoting.  See also: http://www.mail-archive.com/
    # bash-completion-devel@lists.alioth.debian.org/msg01942.html
    [[ ${!2:0:1} == '$' ]] && eval $2=${!2}
} # _quote_readline_by_ref()


# This function turns on "-o filenames" behavior dynamically. It is present
# for bash < 4 reasons. See http://bugs.debian.org/272660#64 for info about
# the bash < 4 compgen hack.
_compopt_o_filenames()
{
    # We test for compopt availability first because directly invoking it on
    # bash < 4 at this point may cause terminal echo to be turned off for some
    # reason, see https://bugzilla.redhat.com/653669 for more info.
    type compopt &>/dev/null && compopt -o filenames 2>/dev/null || \
        compgen -f /non-existing-dir/ >/dev/null
}


# This function performs file and directory completion. It's better than
# simply using 'compgen -f', because it honours spaces in filenames.
# @param $1  If `-d', complete only on directories.  Otherwise filter/pick only
#            completions with `.$1' and the uppercase version of it as file
#            extension.
#
_filedir()
{
    local i IFS=$'\n' xspec

    _tilde "$cur" || return 0

    local -a toks
    local quoted tmp

    _quote_readline_by_ref "$cur" quoted
    toks=( ${toks[@]-} $(
        compgen -d -- "$cur" | {
            while read -r tmp; do
                # TODO: I have removed a "[ -n $tmp ] &&" before 'printf ..',
                #       and everything works again. If this bug suddenly
                #       appears again (i.e. "cd /b<TAB>" becomes "cd /"),
                #       remember to check for other similar conditionals (here
                #       and _filedir_xspec()). --David
                printf '%s\n' $tmp
            done
        }
    ))

    if [[ "$1" != -d ]]; then
        # Munge xspec to contain uppercase version too
        [[ ${BASH_VERSINFO[0]} -ge 4 ]] && \
            xspec=${1:+"!*.@($1|${1^^})"} || \
            xspec=${1:+"!*.@($1|$(printf %s $1 | tr '[:lower:]' '[:upper:]'))"}
        toks=( ${toks[@]-} $( compgen -f -X "$xspec" -- $quoted) )
    fi
    [ ${#toks[@]} -ne 0 ] && _compopt_o_filenames

    COMPREPLY=( "${COMPREPLY[@]}" "${toks[@]}" )
} # _filedir()


# This function splits $cur=--foo=bar into $prev=--foo, $cur=bar, making it
# easier to support both "--foo bar" and "--foo=bar" style completions.
# Returns 0 if current option was split, 1 otherwise.
#
_split_longopt()
{
    if [[ "$cur" == --?*=* ]]; then
        # Cut also backslash before '=' in case it ended up there
        # for some reason.
        prev="${cur%%?(\\)=*}"
        cur="${cur#*=}"
        return 0
    fi

    return 1
}

# This function tries to parse the help output of the given command.
# @param $1  command
# @param $2  command options (default: --help)
#
_parse_help() {
    $1 ${2:---help} 2>&1 | sed -e '/^[[:space:]]*-/!d' -e 's|[,/]| |g' | \
        awk '{ print $1; if ($2 ~ /^-/) { print $2 } }' | sed -e 's|[<=].*||'
}

# This function completes on signal names
#
_signals()
{
    local i

    # standard signal completion is rather braindead, so we need
    # to hack around to get what we want here, which is to
    # complete on a dash, followed by the signal name minus
    # the SIG prefix
    COMPREPLY=( $( compgen -A signal SIG${cur#-} ))
    for (( i=0; i < ${#COMPREPLY[@]}; i++ )); do
        COMPREPLY[i]=-${COMPREPLY[i]#SIG}
    done
}

# This function completes on known mac addresses
#
_mac_addresses()
{
    local re='\([A-Fa-f0-9]\{2\}:\)\{5\}[A-Fa-f0-9]\{2\}'
    local PATH="$PATH:/sbin:/usr/sbin"

    # Local interfaces (Linux only?)
    COMPREPLY=( "${COMPREPLY[@]}" $( ifconfig -a 2>/dev/null | sed -ne \
        "s/.*[[:space:]]HWaddr[[:space:]]\{1,\}\($re\)[[:space:]]*$/\1/p" ) )

    # ARP cache
    COMPREPLY=( "${COMPREPLY[@]}" $( arp -an 2>/dev/null | sed -ne \
        "s/.*[[:space:]]\($re\)[[:space:]].*/\1/p" -ne \
        "s/.*[[:space:]]\($re\)[[:space:]]*$/\1/p" ) )

    # /etc/ethers
    COMPREPLY=( "${COMPREPLY[@]}" $( sed -ne \
        "s/^[[:space:]]*\($re\)[[:space:]].*/\1/p" /etc/ethers 2>/dev/null ) )

    COMPREPLY=( $( compgen -W '${COMPREPLY[@]}' -- "$cur" ) )
    __ltrim_colon_completions "$cur"
}

# This function completes on configured network interfaces
#
_configured_interfaces()
{
    if [ -f /etc/debian_version ]; then
        # Debian system
        COMPREPLY=( $( compgen -W "$( sed -ne 's|^iface \([^ ]\{1,\}\).*$|\1|p'\
            /etc/network/interfaces )" -- "$cur" ) )
    elif [ -f /etc/SuSE-release ]; then
        # SuSE system
        COMPREPLY=( $( compgen -W "$( printf '%s\n' \
            /etc/sysconfig/network/ifcfg-* | \
            sed -ne 's|.*ifcfg-\(.*\)|\1|p' )" -- "$cur" ) )
    elif [ -f /etc/pld-release ]; then
        # PLD Linux
        COMPREPLY=( $( compgen -W "$( command ls -B \
            /etc/sysconfig/interfaces | \
            sed -ne 's|.*ifcfg-\(.*\)|\1|p' )" -- "$cur" ) )
    else
        # Assume Red Hat
        COMPREPLY=( $( compgen -W "$( printf '%s\n' \
            /etc/sysconfig/network-scripts/ifcfg-* | \
            sed -ne 's|.*ifcfg-\(.*\)|\1|p' )" -- "$cur" ) )
    fi
}

# This function completes on available kernels
#
_kernel_versions()
{
    COMPREPLY=( $( compgen -W '$( command ls /lib/modules )' -- "$cur" ) )
}

# This function completes on all available network interfaces
# -a: restrict to active interfaces only
# -w: restrict to wireless interfaces only
#
_available_interfaces()
{
    local cmd

    if [ "${1:-}" = -w ]; then
        cmd="iwconfig"
    elif [ "${1:-}" = -a ]; then
        cmd="ifconfig"
    else
        cmd="ifconfig -a"
    fi

    COMPREPLY=( $( eval PATH="$PATH:/sbin" $cmd 2>/dev/null | \
        awk '/^[^ \t]/ { print $1 }' ) )
    COMPREPLY=( $( compgen -W '${COMPREPLY[@]/%[[:punct:]]/}' -- "$cur" ) )
}


# Perform tilde (~) completion
# @return  True (0) if completion needs further processing, 
#          False (> 0) if tilde is followed by a valid username, completions
#          are put in COMPREPLY and no further processing is necessary.
_tilde() {
    local result=0
    # Does $1 start with tilde (~) and doesn't contain slash (/)?
    if [[ ${1:0:1} == "~" && $1 == ${1//\/} ]]; then
        _compopt_o_filenames
        # Try generate username completions
        COMPREPLY=( $( compgen -P '~' -u "${1#\~}" ) )
        result=${#COMPREPLY[@]}
    fi
    return $result
}


# Expand variable starting with tilde (~)
# We want to expand ~foo/... to /home/foo/... to avoid problems when
# word-to-complete starting with a tilde is fed to commands and ending up
# quoted instead of expanded.
# Only the first portion of the variable from the tilde up to the first slash
# (~../) is expanded.  The remainder of the variable, containing for example
# a dollar sign variable ($) or asterisk (*) is not expanded.
# Example usage:
#
#    $ v="~"; __expand_tilde_by_ref v; echo "$v"
#
# Example output:
#
#       v                  output
#    --------         ----------------
#    ~                /home/user
#    ~foo/bar         /home/foo/bar
#    ~foo/$HOME       /home/foo/$HOME
#    ~foo/a  b        /home/foo/a  b
#    ~foo/*           /home/foo/*
#  
# @param $1  Name of variable (not the value of the variable) to expand
__expand_tilde_by_ref() {
    # Does $1 start with tilde (~)?
    if [ "${!1:0:1}" = "~" ]; then
        # Does $1 contain slash (/)?
        if [ "${!1}" != "${!1//\/}" ]; then
            # Yes, $1 contains slash;
            # 1: Remove * including and after first slash (/), i.e. "~a/b"
            #    becomes "~a".  Double quotes allow eval.
            # 2: Remove * before the first slash (/), i.e. "~a/b"
            #    becomes "b".  Single quotes prevent eval.
            #       +-----1----+ +---2----+
            eval $1="${!1/%\/*}"/'${!1#*/}'
        else 
            # No, $1 doesn't contain slash
            eval $1="${!1}"
        fi
    fi
} # __expand_tilde_by_ref()


# This function expands tildes in pathnames
#
_expand()
{
    # FIXME: Why was this here?
    #[ "$cur" != "${cur%\\}" ] && cur="$cur\\"

    # Expand ~username type directory specifications.  We want to expand
    # ~foo/... to /home/foo/... to avoid problems when $cur starting with
    # a tilde is fed to commands and ending up quoted instead of expanded.

    if [[ "$cur" == \~*/* ]]; then
        eval cur=$cur
    elif [[ "$cur" == \~* ]]; then
        cur=${cur#\~}
        COMPREPLY=( $( compgen -P '~' -u "$cur" ) )
        [ ${#COMPREPLY[@]} -eq 1 ] && eval COMPREPLY[0]=${COMPREPLY[0]}
        return ${#COMPREPLY[@]}
    fi
}

# This function completes on process IDs.
# AIX and Solaris ps prefers X/Open syntax.
[[ $UNAME == SunOS || $UNAME == AIX ]] &&
_pids()
{
    COMPREPLY=( $( compgen -W '$( command ps -efo pid | sed 1d )' -- "$cur" ))
} ||
_pids()
{
    COMPREPLY=( $( compgen -W '$( command ps axo pid= )' -- "$cur" ) )
}

# This function completes on process group IDs.
# AIX and SunOS prefer X/Open, all else should be BSD.
[[ $UNAME == SunOS || $UNAME == AIX ]] &&
_pgids()
{
    COMPREPLY=( $( compgen -W '$( command ps -efo pgid | sed 1d )' -- "$cur" ))
} ||
_pgids()
{
    COMPREPLY=( $( compgen -W '$( command ps axo pgid= )' -- "$cur" ))
}

# This function completes on process names.
# AIX and SunOS prefer X/Open, all else should be BSD.
[[ $UNAME == SunOS || $UNAME == AIX ]] &&
_pnames()
{
    COMPREPLY=( $( compgen -X '<defunct>' -W '$( command ps -efo comm | \
        sed -e 1d -e "s:.*/::" -e "s/^-//" | sort -u )' -- "$cur" ) )
} ||
_pnames()
{
    # FIXME: completes "[kblockd/0]" to "0". Previously it was completed
    # to "kblockd" which isn't correct either. "kblockd/0" would be
    # arguably most correct, but killall from psmisc 22 treats arguments
    # containing "/" specially unless -r is given so that wouldn't quite
    # work either. Perhaps it'd be best to not complete these to anything
    # for now.
    # Not using "ps axo comm" because under some Linux kernels, it
    # truncates command names (see e.g. http://bugs.debian.org/497540#19)
    COMPREPLY=( $( compgen -X '<defunct>' -W '$( command ps axo command= | \
        sed -e "s/ .*//" -e "s:.*/::" -e "s/:$//" -e "s/^[[(-]//" \
            -e "s/[])]$//" | sort -u )' -- "$cur" ) )
}

# This function completes on user IDs
#
_uids()
{
    if type getent &>/dev/null; then
        COMPREPLY=( $( compgen -W '$( getent passwd | cut -d: -f3 )' -- "$cur" ) )
    elif type perl &>/dev/null; then
        COMPREPLY=( $( compgen -W '$( perl -e '"'"'while (($uid) = (getpwent)[2]) { print $uid . "\n" }'"'"' )' -- "$cur" ) )
    else
        # make do with /etc/passwd
        COMPREPLY=( $( compgen -W '$( cut -d: -f3 /etc/passwd )' -- "$cur" ) )
    fi
}

# This function completes on group IDs
#
_gids()
{
    if type getent &>/dev/null; then
        COMPREPLY=( $( compgen -W '$( getent group | cut -d: -f3 )' \
            -- "$cur" ) )
    elif type perl &>/dev/null; then
        COMPREPLY=( $( compgen -W '$( perl -e '"'"'while (($gid) = (getgrent)[2]) { print $gid . "\n" }'"'"' )' -- "$cur" ) )
    else
        # make do with /etc/group
        COMPREPLY=( $( compgen -W '$( cut -d: -f3 /etc/group )' -- "$cur" ) )
    fi
}

# This function completes on services
#
_services()
{
    local sysvdir famdir
    [ -d /etc/rc.d/init.d ] && sysvdir=/etc/rc.d/init.d || sysvdir=/etc/init.d
    famdir=/etc/xinetd.d
    COMPREPLY=( $( printf '%s\n' \
        $sysvdir/!(*.rpm@(orig|new|save)|*~|functions) ) )

    if [ -d $famdir ]; then
        COMPREPLY=( "${COMPREPLY[@]}" $( printf '%s\n' \
            $famdir/!(*.rpm@(orig|new|save)|*~) ) )
    fi

    COMPREPLY=( $( compgen -W '${COMPREPLY[@]#@($sysvdir|$famdir)/}' -- "$cur" ) )
}

# This function completes on modules
#
_modules()
{
    local modpath
    modpath=/lib/modules/$1
    COMPREPLY=( $( compgen -W "$( command ls -R $modpath | \
        sed -ne 's/^\(.*\)\.k\{0,1\}o\(\.gz\)\{0,1\}$/\1/p' )" -- "$cur" ) )
}

# This function completes on installed modules
#
_installed_modules()
{
    COMPREPLY=( $( compgen -W "$( PATH="$PATH:/sbin" lsmod | \
        awk '{if (NR != 1) print $1}' )" -- "$1" ) )
}

# This function completes on user or user:group format; as for chown and cpio.
#
# The : must be added manually; it will only complete usernames initially.
# The legacy user.group format is not supported.
#
# @param $1  If -u, only return users/groups the user has access to in
#            context of current completion.
_usergroup()
{
    if [[ $cur = *\\\\* || $cur = *:*:* ]]; then
        # Give up early on if something seems horribly wrong.
        return
    elif [[ $cur = *\\:* ]]; then
        # Completing group after 'user\:gr<TAB>'.
        # Reply with a list of groups prefixed with 'user:', readline will
        # escape to the colon.
        local prefix
        prefix=${cur%%*([^:])}
        prefix=${prefix//\\}
        local mycur="${cur#*[:]}"
        if [[ $1 == -u ]]; then
            _allowed_groups "$mycur"
        else
            local IFS=$'\n'
            COMPREPLY=( $( compgen -g -- "$mycur" ) )
        fi
        COMPREPLY=( $( compgen -P "$prefix" -W "${COMPREPLY[@]}" ) )
    elif [[ $cur = *:* ]]; then
        # Completing group after 'user:gr<TAB>'.
        # Reply with a list of unprefixed groups since readline with split on :
        # and only replace the 'gr' part
        local mycur="${cur#*:}"
        if [[ $1 == -u ]]; then
            _allowed_groups "$mycur"
        else
            local IFS=$'\n'
            COMPREPLY=( $( compgen -g -- "$mycur" ) )
        fi
    else
        # Completing a partial 'usernam<TAB>'.
        #
        # Don't suffix with a : because readline will escape it and add a
        # slash. It's better to complete into 'chown username ' than 'chown
        # username\:'.
        if [[ $1 == -u ]]; then
            _allowed_users "$cur"
        else
            local IFS=$'\n'
            COMPREPLY=( $( compgen -u -- "$cur" ) )
        fi
    fi
}

_allowed_users()
{
    if _complete_as_root; then
        local IFS=$'\n'
        COMPREPLY=( $( compgen -u -- "${1:-$cur}" ) )
    else
        local IFS=$'\n '
        COMPREPLY=( $( compgen -W \
            "$( id -un 2>/dev/null || whoami 2>/dev/null )" -- "${1:-$cur}" ) )
    fi
}

_allowed_groups()
{
    if _complete_as_root; then
        local IFS=$'\n'
        COMPREPLY=( $( compgen -g -- "$1" ) )
    else
        local IFS=$'\n '
        COMPREPLY=( $( compgen -W \
            "$( id -Gn 2>/dev/null || groups 2>/dev/null )" -- "$1" ) )
    fi
}

# This function completes on valid shells
#
_shells()
{
    COMPREPLY=( "${COMPREPLY[@]}" $( compgen -W \
        '$( command grep "^[[:space:]]*/" /etc/shells 2>/dev/null )' \
        -- "$cur" ) )
}

# This function completes on valid filesystem types
#
_fstypes()
{
    local fss

    if [ -e /proc/filesystems ] ; then
        # Linux
        fss="$( cut -d$'\t' -f2 /proc/filesystems )
             $( awk '! /\*/ { print $NF }' /etc/filesystems 2>/dev/null )"
    else
        # Generic
        fss="$( awk '/^[ \t]*[^#]/ { print $3 }' /etc/fstab 2>/dev/null )
             $( awk '/^[ \t]*[^#]/ { print $3 }' /etc/mnttab 2>/dev/null )
             $( awk '/^[ \t]*[^#]/ { print $4 }' /etc/vfstab 2>/dev/null )
             $( awk '{ print $1 }' /etc/dfs/fstypes 2>/dev/null )
             $( [ -d /etc/fs ] && command ls /etc/fs )"
    fi

    [ -n "$fss" ] && \
        COMPREPLY=( "${COMPREPLY[@]}" $( compgen -W "$fss" -- "$cur" ) )
}

# Get real command.
# - arg: $1  Command
# - stdout:  Filename of command in PATH with possible symbolic links resolved.
#            Empty string if command not found.
# - return:  True (0) if command found, False (> 0) if not.
_realcommand()
{
    type -P "$1" > /dev/null && {
        if type -p realpath > /dev/null; then
            realpath "$(type -P "$1")"
        elif type -p readlink > /dev/null; then
            readlink "$(type -P "$1")"
        else
            type -P "$1"
        fi
    }
}

# This function returns the first arugment, excluding options
# @param $1 chars  Characters out of $COMP_WORDBREAKS which should
#     NOT be considered word breaks. See __reassemble_comp_words_by_ref.
_get_first_arg()
{
    local i

    arg=
    for (( i=1; i < COMP_CWORD; i++ )); do
        if [[ "${COMP_WORDS[i]}" != -* ]]; then
            arg=${COMP_WORDS[i]}
            break
        fi
    done
}


# This function counts the number of args, excluding options
# @param $1 chars  Characters out of $COMP_WORDBREAKS which should
#     NOT be considered word breaks. See __reassemble_comp_words_by_ref.
_count_args()
{
    local i cword words
    __reassemble_comp_words_by_ref "$1" words cword

    args=1
    for i in "${words[@]:1:cword-1}"; do
        [[ "$i" != -* ]] && args=$(($args+1))
    done
}

# This function completes on PCI IDs
#
_pci_ids()
{
    COMPREPLY=( ${COMPREPLY[@]:-} $( compgen -W \
        "$( PATH="$PATH:/sbin" lspci -n | awk '{print $3}')" -- "$cur" ) )
}

# This function completes on USB IDs
#
_usb_ids()
{
    COMPREPLY=( ${COMPREPLY[@]:-} $( compgen -W \
        "$( PATH="$PATH:/sbin" lsusb | awk '{print $6}' )" -- "$cur" ) )
}

# CD device names
_cd_devices()
{
    COMPREPLY=( "${COMPREPLY[@]}"
        $( compgen -f -d -X "!*/?([amrs])cd*" -- "${cur:-/dev/}" ) )
}

# DVD device names
_dvd_devices()
{
    COMPREPLY=( "${COMPREPLY[@]}"
        $( compgen -f -d -X "!*/?(r)dvd*" -- "${cur:-/dev/}" ) )
}

# start of section containing completion functions for external programs

# a little help for FreeBSD ports users
[ $UNAME = FreeBSD ] && complete -W 'index search fetch fetch-list extract \
    patch configure build install reinstall deinstall clean clean-depends \
    kernel buildworld' make

# This function provides simple user@host completion
#
_user_at_host() {
    local cur

    COMPREPLY=()
    _get_comp_words_by_ref -n : cur

    if [[ $cur == *@* ]]; then
        _known_hosts_real "$cur"
    else
        COMPREPLY=( $( compgen -u -- "$cur" ) )
    fi

    return 0
}
shopt -u hostcomplete && complete -F _user_at_host -o nospace talk ytalk finger

# NOTE: Using this function as a helper function is deprecated.  Use
#       `_known_hosts_real' instead.
_known_hosts()
{
    local options
    COMPREPLY=()

    # NOTE: Using `_known_hosts' as a helper function and passing options
    #       to `_known_hosts' is deprecated: Use `_known_hosts_real' instead.
    [[ "$1" == -a || "$2" == -a ]] && options=-a
    [[ "$1" == -c || "$2" == -c ]] && options="$options -c"
    _known_hosts_real $options "$(_get_cword :)"
} # _known_hosts()

# Helper function for completing _known_hosts.
# This function performs host completion based on ssh's config and known_hosts
# files, as well as hostnames reported by avahi-browse if
# COMP_KNOWN_HOSTS_WITH_AVAHI is set to a non-empty value.  Also hosts from
# HOSTFILE (compgen -A hostname) are added, unless
# COMP_KNOWN_HOSTS_WITH_HOSTFILE is set to an empty value.
# Usage: _known_hosts_real [OPTIONS] CWORD
# Options:  -a             Use aliases
#           -c             Use `:' suffix
#           -F configfile  Use `configfile' for configuration settings
#           -p PREFIX      Use PREFIX
# Return: Completions, starting with CWORD, are added to COMPREPLY[]
_known_hosts_real()
{
    local configfile flag prefix
    local cur curd awkcur user suffix aliases i host
    local -a kh khd config

    local OPTIND=1
    while getopts "acF:p:" flag "$@"; do
        case $flag in
            a) aliases='yes' ;;
            c) suffix=':' ;;
            F) configfile=$OPTARG ;;
            p) prefix=$OPTARG ;;
        esac
    done
    [ $# -lt $OPTIND ] && echo "error: $FUNCNAME: missing mandatory argument CWORD"
    cur=${!OPTIND}; let "OPTIND += 1"
    [ $# -ge $OPTIND ] && echo "error: $FUNCNAME("$@"): unprocessed arguments:"\
    $(while [ $# -ge $OPTIND ]; do printf '%s\n' ${!OPTIND}; shift; done)

    [[ $cur == *@* ]] && user=${cur%@*}@ && cur=${cur#*@}
    kh=()

    # ssh config files
    if [ -n "$configfile" ]; then
        [ -r "$configfile" ] &&
        config=( "${config[@]}" "$configfile" )
    else
        for i in /etc/ssh/ssh_config "${HOME}/.ssh/config" \
            "${HOME}/.ssh2/config"; do
            [ -r $i ] && config=( "${config[@]}" "$i" )
        done
    fi

    # Known hosts files from configs
    if [ ${#config[@]} -gt 0 ]; then
        local OIFS=$IFS IFS=$'\n'
        local -a tmpkh
        # expand paths (if present) to global and user known hosts files
        # TODO(?): try to make known hosts files with more than one consecutive
        #          spaces in their name work (watch out for ~ expansion
        #          breakage! Alioth#311595)
        tmpkh=( $( awk 'sub("^[ \t]*([Gg][Ll][Oo][Bb][Aa][Ll]|[Uu][Ss][Ee][Rr])[Kk][Nn][Oo][Ww][Nn][Hh][Oo][Ss][Tt][Ss][Ff][Ii][Ll][Ee][ \t]+", "") { print $0 }' "${config[@]}" | sort -u ) )
        for i in "${tmpkh[@]}"; do
            # Remove possible quotes
            i=${i//\"}
            # Eval/expand possible `~' or `~user'
            __expand_tilde_by_ref i
            [ -r "$i" ] && kh=( "${kh[@]}" "$i" )
        done
        IFS=$OIFS
    fi

    if [ -z "$configfile" ]; then
        # Global and user known_hosts files
        for i in /etc/ssh/ssh_known_hosts /etc/ssh/ssh_known_hosts2 \
            /etc/known_hosts /etc/known_hosts2 ~/.ssh/known_hosts \
            ~/.ssh/known_hosts2; do
            [ -r $i ] && kh=( "${kh[@]}" $i )
        done
        for i in /etc/ssh2/knownhosts ~/.ssh2/hostkeys; do
            [ -d $i ] && khd=( "${khd[@]}" $i/*pub )
        done
    fi

    # If we have known_hosts files to use
    if [[ ${#kh[@]} -gt 0 || ${#khd[@]} -gt 0 ]]; then
        # Escape slashes and dots in paths for awk
        awkcur=${cur//\//\\\/}
        awkcur=${awkcur//\./\\\.}
        curd=$awkcur

        if [[ "$awkcur" == [0-9]*[.:]* ]]; then
            # Digits followed by a dot or a colon - just search for that
            awkcur="^$awkcur[.:]*"
        elif [[ "$awkcur" == [0-9]* ]]; then
            # Digits followed by no dot or colon - search for digits followed
            # by a dot or a colon
            awkcur="^$awkcur.*[.:]"
        elif [ -z "$awkcur" ]; then
            # A blank - search for a dot, a colon, or an alpha character
            awkcur="[a-z.:]"
        else
            awkcur="^$awkcur"
        fi

        if [ ${#kh[@]} -gt 0 ]; then
            # FS needs to look for a comma separated list
            COMPREPLY=( "${COMPREPLY[@]}" $( awk 'BEGIN {FS=","}
            /^\s*[^|\#]/ {for (i=1; i<=2; ++i) { \
            sub(" .*$", "", $i); \
            sub("^\\[", "", $i); sub("\\](:[0-9]+)?$", "", $i); \
            if ($i ~ /'"$awkcur"'/) {print $i} \
            }}' "${kh[@]}" 2>/dev/null ) )
        fi
        if [ ${#khd[@]} -gt 0 ]; then
            # Needs to look for files called
            # .../.ssh2/key_22_<hostname>.pub
            # dont fork any processes, because in a cluster environment,
            # there can be hundreds of hostkeys
            for i in "${khd[@]}" ; do
                if [[ "$i" == *key_22_$curd*.pub && -r "$i" ]]; then
                    host=${i/#*key_22_/}
                    host=${host/%.pub/}
                    COMPREPLY=( "${COMPREPLY[@]}" $host )
                fi
            done
        fi

        # apply suffix and prefix
        for (( i=0; i < ${#COMPREPLY[@]}; i++ )); do
            COMPREPLY[i]=$prefix$user${COMPREPLY[i]}$suffix
        done
    fi

    # append any available aliases from config files
    if [[ ${#config[@]} -gt 0 && -n "$aliases" ]]; then
        local hosts=$( sed -ne 's/^[[:blank:]]*[Hh][Oo][Ss][Tt]\([Nn][Aa][Mm][Ee]\)\{0,1\}[[:blank:]]\{1,\}\([^#*?]*\)\(#.*\)\{0,1\}$/\2/p' "${config[@]}" )
        COMPREPLY=( "${COMPREPLY[@]}" $( compgen  -P "$prefix$user" \
            -S "$suffix" -W "$hosts" -- "$cur" ) )
    fi

    # Add hosts reported by avahi-browse, if desired and it's available.
    if [[ ${COMP_KNOWN_HOSTS_WITH_AVAHI:-} ]] && \
        type avahi-browse &>/dev/null; then
        # The original call to avahi-browse also had "-k", to avoid lookups
        # into avahi's services DB. We don't need the name of the service, and
        # if it contains ";", it may mistify the result. But on Gentoo (at
        # least), -k wasn't available (even if mentioned in the manpage) some
        # time ago, so...
        COMPREPLY=( "${COMPREPLY[@]}" $( \
            compgen -P "$prefix$user" -S "$suffix" -W \
            "$( avahi-browse -cpr _workstation._tcp 2>/dev/null | \
                 awk -F';' '/^=/ { print $7 }' | sort -u )" -- "$cur" ) )
    fi

    # Add results of normal hostname completion, unless
    # `COMP_KNOWN_HOSTS_WITH_HOSTFILE' is set to an empty value.
    if [ -n "${COMP_KNOWN_HOSTS_WITH_HOSTFILE-1}" ]; then
        COMPREPLY=( "${COMPREPLY[@]}"
            $( compgen -A hostname -P "$prefix$user" -S "$suffix" -- "$cur" ) )
    fi

    __ltrim_colon_completions "$prefix$user$cur"

    return 0
} # _known_hosts_real()
complete -F _known_hosts traceroute traceroute6 tracepath tracepath6 ping \
    ping6 fping fping6 telnet host nslookup rsh rlogin ftp dig mtr \
    ssh-installkeys showmount


# This meta-cd function observes the CDPATH variable, so that cd additionally
# completes on directories under those specified in CDPATH.
#
_cd()
{
    local cur IFS=$'\n' i j k
    _get_comp_words_by_ref cur

    # try to allow variable completion
    if [[ "$cur" == ?(\\)\$* ]]; then
        COMPREPLY=( $( compgen -v -P '$' -- "${cur#?(\\)$}" ) )
        return 0
    fi

    _compopt_o_filenames

    # Use standard dir completion if no CDPATH or parameter starts with /,
    # ./ or ../
    if [[ -z "${CDPATH:-}" || "$cur" == ?(.)?(.)/* ]]; then
        _filedir -d
        return 0
    fi

    local -r mark_dirs=$(_rl_enabled mark-directories && echo y)
    local -r mark_symdirs=$(_rl_enabled mark-symlinked-directories && echo y)

    # we have a CDPATH, so loop on its contents
    for i in ${CDPATH//:/$'\n'}; do
        # create an array of matched subdirs
        k="${#COMPREPLY[@]}"
        for j in $( compgen -d $i/$cur ); do
            if [[ ( $mark_symdirs && -h $j || $mark_dirs && ! -h $j ) && ! -d ${j#$i/} ]]; then
                j="${j}/"
            fi
            COMPREPLY[k++]=${j#$i/}
        done
    done

    _filedir -d

    if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
        i=${COMPREPLY[0]}
        if [[ "$i" == "$cur" && $i != "*/" ]]; then
            COMPREPLY[0]="${i}/"
        fi
    fi

    return 0
}
if shopt -q cdable_vars; then
    complete -v -F _cd -o nospace cd
else
    complete -F _cd -o nospace cd
fi

# a wrapper method for the next one, when the offset is unknown
_command()
{
    local offset i

    # find actual offset, as position of the first non-option
    offset=1
    for (( i=1; i <= COMP_CWORD; i++ )); do
        if [[ "${COMP_WORDS[i]}" != -* ]]; then
            offset=$i
            break
        fi
    done
    _command_offset $offset
}

# A meta-command completion function for commands like sudo(8), which need to
# first complete on a command, then complete according to that command's own
# completion definition - currently not quite foolproof (e.g. mount and umount
# don't work properly), but still quite useful.
#
_command_offset()
{
    local cur func cline cspec noglob cmd i char_offset word_offset \
        _COMMAND_FUNC _COMMAND_FUNC_ARGS

    word_offset=$1

    # rewrite current completion context before invoking
    # actual command completion

    # find new first word position, then
    # rewrite COMP_LINE and adjust COMP_POINT
    local first_word=${COMP_WORDS[$word_offset]}
    for (( i=0; i <= ${#COMP_LINE}; i++ )); do
        if [[ "${COMP_LINE:$i:${#first_word}}" == "$first_word" ]]; then
            char_offset=$i
            break
        fi
    done
    COMP_LINE=${COMP_LINE:$char_offset}
    COMP_POINT=$(( COMP_POINT - $char_offset ))

    # shift COMP_WORDS elements and adjust COMP_CWORD
    for (( i=0; i <= COMP_CWORD - $word_offset; i++ )); do
        COMP_WORDS[i]=${COMP_WORDS[i+$word_offset]}
    done
    for (( i; i <= COMP_CWORD; i++ )); do
        unset COMP_WORDS[i];
    done
    COMP_CWORD=$(( $COMP_CWORD - $word_offset ))

    COMPREPLY=()
    _get_comp_words_by_ref cur

    if [[ $COMP_CWORD -eq 0 ]]; then
        _compopt_o_filenames
        COMPREPLY=( $( compgen -c -- "$cur" ) )
    else
        cmd=${COMP_WORDS[0]}
        if complete -p ${cmd##*/} &>/dev/null; then
            cspec=$( complete -p ${cmd##*/} )
            if [ "${cspec#* -F }" != "$cspec" ]; then
                # complete -F <function>

                # get function name
                func=${cspec#*-F }
                func=${func%% *}

                if [[ ${#COMP_WORDS[@]} -ge 2 ]]; then
                    $func $cmd "${COMP_WORDS[${#COMP_WORDS[@]}-1]}" "${COMP_WORDS[${#COMP_WORDS[@]}-2]}"
                else
                    $func $cmd "${COMP_WORDS[${#COMP_WORDS[@]}-1]}"
                fi

                # remove any \: generated by a command that doesn't
                # default to filenames or dirnames (e.g. sudo chown)
                # FIXME: I'm pretty sure this does not work!
                if [ "${cspec#*-o }" != "$cspec" ]; then
                    cspec=${cspec#*-o }
                    cspec=${cspec%% *}
                    if [[ "$cspec" != @(dir|file)names ]]; then
                        COMPREPLY=("${COMPREPLY[@]//\\\\:/:}")
                    else
                        _compopt_o_filenames
                    fi
                fi
            elif [ -n "$cspec" ]; then
                cspec=${cspec#complete};
                cspec=${cspec%%${cmd##*/}};
                COMPREPLY=( $( eval compgen "$cspec" -- "$cur" ) );
            fi
        elif [ ${#COMPREPLY[@]} -eq 0 ]; then
            _filedir
        fi
    fi
}
complete -F _command aoss command do else eval exec ltrace nice nohup padsp \
    then time tsocks vsound xargs

_root_command()
{
    local PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin
    local root_command=$1
    _command $1 $2 $3
}
complete -F _root_command fakeroot gksu gksudo kdesudo really sudo

# Return true if the completion should be treated as running as root
_complete_as_root()
{
    [[ $EUID -eq 0 || ${root_command:-} ]]
}

_longopt()
{
    local cur prev split=false
    _get_comp_words_by_ref -n = cur prev

    _split_longopt && split=true

    case "$prev" in
        --*[Dd][Ii][Rr]*)
            _filedir -d
            return 0
            ;;
        --*[Ff][Ii][Ll][Ee]*|--*[Pp][Aa][Tt][Hh]*)
            _filedir
            return 0
            ;;
    esac

    $split && return 0

    # Syntax problem here
    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $( compgen -W "$( $1 --help 2>&1 | \
            sed -ne 's/.*\(--[-A-Za-z0-9]\{1,\}\).*/\1/p' | sort -u )" \
            -- "$cur" ) )
    elif [[ "$1" == @(mk|rm)dir ]]; then
        _filedir -d
    else
        _filedir
    fi
}
# makeinfo and texi2dvi are defined elsewhere.
for i in a2ps awk bash bc bison cat colordiff cp csplit \
    curl cut date df diff dir du enscript env expand fmt fold gperf gprof \
    grep grub head indent irb ld ldd less ln ls m4 md5sum mkdir mkfifo mknod \
    mv netstat nl nm objcopy objdump od paste patch pr ptx readelf rm rmdir \
    sed seq sha{,1,224,256,384,512}sum shar sort split strip tac tail tee \
    texindex touch tr uname unexpand uniq units vdir wc wget who; do
    have $i && complete -F _longopt -o default $i
done
unset i

_filedir_xspec()
{
    local IFS cur xspec

    IFS=$'\n'
    COMPREPLY=()
    _get_comp_words_by_ref cur

    _expand || return 0

    # get first exclusion compspec that matches this command
    xspec=$( awk "/^complete[ \t]+.*[ \t]${1##*/}([ \t]|\$)/ { print \$0; exit }" \
        "$BASH_COMPLETION" )
    # prune to leave nothing but the -X spec
    xspec=${xspec#*-X }
    xspec=${xspec%% *}

    local -a toks
    local tmp

    toks=( ${toks[@]-} $(
        compgen -d -- "$(quote_readline "$cur")" | {
        while read -r tmp; do
            # see long TODO comment in _filedir() --David
            printf '%s\n' $tmp
        done
        }
        ))

    # Munge xspec to contain uppercase version too
    eval xspec="${xspec}"
    local matchop=!
    if [[ $xspec == !* ]]; then
        xspec=${xspec#!}
        matchop=@
    fi
    [[ ${BASH_VERSINFO[0]} -ge 4 ]] && \
        xspec="$matchop($xspec|${xspec^^})" || \
        xspec="$matchop($xspec|$(printf %s $xspec | tr '[:lower:]' '[:upper:]'))"

    toks=( ${toks[@]-} $(
        eval compgen -f -X "!$xspec" -- "\$(quote_readline "\$cur")" | {
        while read -r tmp; do
            [ -n $tmp ] && printf '%s\n' $tmp
        done
        }
        ))

    [ ${#toks[@]} -ne 0 ] && _compopt_o_filenames
    COMPREPLY=( "${toks[@]}" )
}
list=( $( sed -ne '/^# START exclude/,/^# FINISH exclude/p' "$BASH_COMPLETION" | \
    # read exclusion compspecs
    (
    while read line
    do
        # ignore compspecs that are commented out
        if [ "${line#\#}" != "$line" ]; then continue; fi
        line=${line%# START exclude*}
        line=${line%# FINISH exclude*}
        line=${line##*\'}
        list=( "${list[@]}" $line )
    done
    printf '%s ' "${list[@]}"
    )
    ) )
# remove previous compspecs
if [ ${#list[@]} -gt 0 ]; then
    eval complete -r ${list[@]}
    # install new compspecs
    eval complete -F _filedir_xspec "${list[@]}"
fi
unset list

# source completion directory definitions
if [[ -d $BASH_COMPLETION_COMPAT_DIR && -r $BASH_COMPLETION_COMPAT_DIR && \
    -x $BASH_COMPLETION_COMPAT_DIR ]]; then
    for i in $(LC_ALL=C command ls "$BASH_COMPLETION_COMPAT_DIR"); do
        i=$BASH_COMPLETION_COMPAT_DIR/$i
        [[ ${i##*/} != @(*~|*.bak|*.swp|\#*\#|*.dpkg*|*.rpm@(orig|new|save)|Makefile*) \
            && -f $i && -r $i ]] && . "$i"
    done
fi
if [[ $BASH_COMPLETION_DIR != $BASH_COMPLETION_COMPAT_DIR && \
    -d $BASH_COMPLETION_DIR && -r $BASH_COMPLETION_DIR && \
    -x $BASH_COMPLETION_DIR ]]; then
    for i in $(LC_ALL=C command ls "$BASH_COMPLETION_DIR"); do
        i=$BASH_COMPLETION_DIR/$i
        [[ ${i##*/} != @(*~|*.bak|*.swp|\#*\#|*.dpkg*|*.rpm@(orig|new|save)|Makefile*) \
            && -f $i && -r $i ]] && . "$i"
    done
fi
unset i

# source user completion file
[[ $BASH_COMPLETION != ~/.bash_completion && -r ~/.bash_completion ]] \
    && . ~/.bash_completion
unset -f have
unset UNAME USERLAND have

set $BASH_COMPLETION_ORIGINAL_V_VALUE
unset BASH_COMPLETION_ORIGINAL_V_VALUE

# Local variables:
# mode: shell-script
# sh-basic-offset: 4
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: ts=4 sw=4 et filetype=sh



#
#   bash_completion - programmable completion functions for bash 3.2+
#
#   Copyright © 2006-2008, Ian Macdonald <ian@caliban.org>
#             © 2009-2011, Bash Completion Maintainers
#                     <bash-completion-devel@lists.alioth.debian.org>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2, or (at your option)
#   any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software Foundation,
#   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
#   The latest version of this software can be obtained here:
#
#   http://bash-completion.alioth.debian.org/
#
#   RELEASE: 1.3

if [[ $- == *v* ]]; then
    BASH_COMPLETION_ORIGINAL_V_VALUE="-v"
else
    BASH_COMPLETION_ORIGINAL_V_VALUE="+v"
fi

if [[ -n $BASH_COMPLETION_DEBUG ]]; then
    set -v
else
    set +v
fi

# Alter the following to reflect the location of this file.
#
[ -n "$BASH_COMPLETION" ] || BASH_COMPLETION=/usr/local/etc/bash_completion
[ -n "$BASH_COMPLETION_DIR" ] || BASH_COMPLETION_DIR=/usr/local/etc/bash_completion.d
[ -n "$BASH_COMPLETION_COMPAT_DIR" ] || BASH_COMPLETION_COMPAT_DIR=/usr/local/etc/bash_completion.d
readonly BASH_COMPLETION BASH_COMPLETION_DIR BASH_COMPLETION_COMPAT_DIR

# Set a couple of useful vars
#
UNAME=$( uname -s )
# strip OS type and version under Cygwin (e.g. CYGWIN_NT-5.1 => Cygwin)
UNAME=${UNAME/CYGWIN_*/Cygwin}

case ${UNAME} in
    Linux|GNU|GNU/*) USERLAND=GNU ;;
    *) USERLAND=${UNAME} ;;
esac

# Turn on extended globbing and programmable completion
shopt -s extglob progcomp

# A lot of the following one-liners were taken directly from the
# completion examples provided with the bash 2.04 source distribution

# Make directory commands see only directories
complete -d pushd

# The following section lists completions that are redefined later
# Do NOT break these over multiple lines.
#
# START exclude -- do NOT remove this line
# bzcmp, bzdiff, bz*grep, bzless, bzmore intentionally not here, see Debian: #455510
complete -f -X '!*.?(t)bz?(2)' bunzip2 bzcat pbunzip2 pbzcat
complete -f -X '!*.@(zip|[ejw]ar|exe|pk3|wsz|zargo|xpi|sxw|o[tx]t|od[fgpst]|epub|apk)' unzip zipinfo
complete -f -X '*.Z' compress znew
# zcmp, zdiff, z*grep, zless, zmore intentionally not here, see Debian: #455510
complete -f -X '!*.@(Z|[gGd]z|t[ag]z)' gunzip zcat unpigz
complete -f -X '!*.Z' uncompress
# lzcmp, lzdiff intentionally not here, see Debian: #455510
complete -f -X '!*.@(tlz|lzma)' lzcat lzegrep lzfgrep lzgrep lzless lzmore unlzma
complete -f -X '!*.@(?(t)xz|tlz|lzma)' unxz xzcat
complete -f -X '!*.lrz' lrunzip
complete -f -X '!*.@(gif|jp?(e)g|miff|tif?(f)|pn[gm]|p[bgp]m|bmp|xpm|ico|xwd|tga|pcx)' ee
complete -f -X '!*.@(gif|jp?(e)g|tif?(f)|png|p[bgp]m|bmp|x[bp]m|rle|rgb|pcx|fits|pm)' xv qiv
complete -f -X '!*.@(@(?(e)ps|?(E)PS|pdf|PDF)?(.gz|.GZ|.bz2|.BZ2|.Z))' gv ggv kghostview
complete -f -X '!*.@(dvi|DVI)?(.@(gz|Z|bz2))' xdvi kdvi
complete -f -X '!*.dvi' dvips dviselect dvitype dvipdf advi dvipdfm dvipdfmx
complete -f -X '!*.[pf]df' acroread gpdf xpdf
complete -f -X '!*.@(?(e)ps|pdf)' kpdf
complete -f -X '!*.@(@(?(e)ps|?(E)PS|[pf]df|[PF]DF|dvi|DVI)?(.gz|.GZ|.bz2|.BZ2)|cb[rz]|djv?(u)|gif|jp?(e)g|miff|tif?(f)|pn[gm]|p[bgp]m|bmp|xpm|ico|xwd|tga|pcx|fdf)' evince
complete -f -X '!*.@(okular|@(?(e|x)ps|?(E|X)PS|pdf|PDF|dvi|DVI|cb[rz]|CB[RZ]|djv?(u)|DJV?(U)|dvi|DVI|gif|jp?(e)g|miff|tif?(f)|pn[gm]|p[bgp]m|bmp|xpm|ico|xwd|tga|pcx|GIF|JP?(E)G|MIFF|TIF?(F)|PN[GM]|P[BGP]M|BMP|XPM|ICO|XWD|TGA|PCX|epub|EPUB|odt|ODT|fb?(2)|FB?(2)|mobi|MOBI|g3|G3|chm|CHM|fdf|FDF)?(.?(gz|GZ|bz2|BZ2)))' okular
complete -f -X '!*.@(?(e)ps|pdf)' ps2pdf ps2pdf12 ps2pdf13 ps2pdf14 ps2pdfwr
complete -f -X '!*.texi*' makeinfo texi2html
complete -f -X '!*.@(?(la)tex|texi|dtx|ins|ltx)' tex latex slitex jadetex pdfjadetex pdftex pdflatex texi2dvi
complete -f -X '!*.mp3' mpg123 mpg321 madplay
complete -f -X '!*@(.@(mp?(e)g|MP?(E)G|wma|avi|AVI|asf|vob|VOB|bin|dat|divx|DIVX|vcd|ps|pes|fli|flv|FLV|fxm|FXM|viv|rm|ram|yuv|mov|MOV|qt|QT|wmv|mp[234]|MP[234]|m4[pv]|M4[PV]|mkv|MKV|og[gmv]|OG[GMV]|t[ps]|T[PS]|m2t?(s)|M2T?(S)|wav|WAV|flac|FLAC|asx|ASX|mng|MNG|srt|m[eo]d|M[EO]D|s[3t]m|S[3T]M|it|IT|xm|XM)|+([0-9]).@(vdr|VDR))?(.part)' xine aaxine fbxine
complete -f -X '!*@(.@(mp?(e)g|MP?(E)G|wma|avi|AVI|asf|vob|VOB|bin|dat|divx|DIVX|vcd|ps|pes|fli|flv|FLV|fxm|FXM|viv|rm|ram|yuv|mov|MOV|qt|QT|wmv|mp[234]|MP[234]|m4[pv]|M4[PV]|mkv|MKV|og[gmv]|OG[GMV]|t[ps]|T[PS]|m2t?(s)|M2T?(S)|wav|WAV|flac|FLAC|asx|ASX|mng|MNG|srt|m[eo]d|M[EO]D|s[3t]m|S[3T]M|it|IT|xm|XM|iso|ISO)|+([0-9]).@(vdr|VDR))?(.part)' kaffeine dragon
complete -f -X '!*.@(avi|asf|wmv)' aviplay
complete -f -X '!*.@(rm?(j)|ra?(m)|smi?(l))' realplay
complete -f -X '!*.@(mpg|mpeg|avi|mov|qt)' xanim
complete -f -X '!*.@(ogg|m3u|flac|spx)' ogg123
complete -f -X '!*.@(mp3|ogg|pls|m3u)' gqmpeg freeamp
complete -f -X '!*.fig' xfig
complete -f -X '!*.@(mid?(i)|cmf)' playmidi
complete -f -X '!*.@(mid?(i)|rmi|rcp|[gr]36|g18|mod|xm|it|x3m|s[3t]m|kar)' timidity
complete -f -X '!*.@(m[eo]d|s[3t]m|xm|it)' modplugplay modplug123
complete -f -X '*.@(o|so|so.!(conf)|a|[rs]pm|gif|jp?(e)g|mp3|mp?(e)g|avi|asf|ogg|class)' vi vim gvim rvim view rview rgvim rgview gview emacs xemacs sxemacs kate kwrite
complete -f -X '!*.@([eE][xX][eE]?(.[sS][oO])|[cC][oO][mM]|[sS][cC][rR])' wine
complete -f -X '!*.@(zip|z|gz|tgz)' bzme
# konqueror not here on purpose, it's more than a web/html browser
complete -f -X '!*.@(?([xX]|[sS])[hH][tT][mM]?([lL]))' netscape mozilla lynx opera galeon dillo elinks amaya firefox mozilla-firefox iceweasel google-chrome chromium-browser epiphany
complete -f -X '!*.@(sxw|stw|sxg|sgl|doc?([mx])|dot?([mx])|rtf|txt|htm|html|odt|ott|odm)' oowriter
complete -f -X '!*.@(sxi|sti|pps?(x)|ppt?([mx])|pot?([mx])|odp|otp)' ooimpress
complete -f -X '!*.@(sxc|stc|xls?([bmx])|xlw|xlt?([mx])|[ct]sv|ods|ots)' oocalc
complete -f -X '!*.@(sxd|std|sda|sdd|odg|otg)' oodraw
complete -f -X '!*.@(sxm|smf|mml|odf)' oomath
complete -f -X '!*.odb' oobase
complete -f -X '!*.[rs]pm' rpm2cpio
complete -f -X '!*.aux' bibtex
complete -f -X '!*.po' poedit gtranslator kbabel lokalize
complete -f -X '!*.@([Pp][Rr][Gg]|[Cc][Ll][Pp])' harbour gharbour hbpp
complete -f -X '!*.[Hh][Rr][Bb]' hbrun
complete -f -X '!*.ly' lilypond ly2dvi
complete -f -X '!*.@(dif?(f)|?(d)patch)?(.@([gx]z|bz2|lzma))' cdiff
complete -f -X '!*.lyx' lyx
complete -f -X '!@(*.@(ks|jks|jceks|p12|pfx|bks|ubr|gkr|cer|crt|cert|p7b|pkipath|pem|p10|csr|crl)|cacerts)' portecle
complete -f -X '!*.@(mp[234c]|og[ag]|@(fl|a)ac|m4[abp]|spx|tta|w?(a)v|wma|aif?(f)|asf|ape)' kid3 kid3-qt
# FINISH exclude -- do not remove this line

# start of section containing compspecs that can be handled within bash

# user commands see only users
complete -u su write chfn groups slay w sux runuser

# bg completes with stopped jobs
complete -A stopped -P '"%' -S '"' bg

# other job commands
complete -j -P '"%' -S '"' fg jobs disown

# readonly and unset complete with shell variables
complete -v readonly unset

# set completes with set options
complete -A setopt set

# shopt completes with shopt options
complete -A shopt shopt

# helptopics
complete -A helptopic help

# unalias completes with aliases
complete -a unalias

# bind completes with readline bindings (make this more intelligent)
complete -A binding bind

# type and which complete on commands
complete -c command type which

# builtin completes on builtins
complete -b builtin

# start of section containing completion functions called by other functions

# This function checks whether we have a given program on the system.
# No need for bulky functions in memory if we don't.
#
have()
{
    unset -v have
    # Completions for system administrator commands are installed as well in
    # case completion is attempted via `sudo command ...'.
    PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin type $1 &>/dev/null &&
    have="yes"
}

# This function checks whether a given readline variable
# is `on'.
#
_rl_enabled()
{
    [[ "$( bind -v )" = *$1+([[:space:]])on* ]]
}

# This function shell-quotes the argument
quote()
{
    echo \'${1//\'/\'\\\'\'}\' #'# Help vim syntax highlighting
}

# @see _quote_readline_by_ref()
quote_readline()
{
    local quoted
    _quote_readline_by_ref "$1" ret
    printf %s "$ret"
} # quote_readline()


# This function shell-dequotes the argument
dequote()
{
    eval echo "$1" 2> /dev/null
}


# Assign variable one scope above the caller
# Usage: local "$1" && _upvar $1 "value(s)"
# Param: $1  Variable name to assign value to
# Param: $*  Value(s) to assign.  If multiple values, an array is
#            assigned, otherwise a single value is assigned.
# NOTE: For assigning multiple variables, use '_upvars'.  Do NOT
#       use multiple '_upvar' calls, since one '_upvar' call might
#       reassign a variable to be used by another '_upvar' call.
# See: http://fvue.nl/wiki/Bash:_Passing_variables_by_reference
_upvar() {
    if unset -v "$1"; then           # Unset & validate varname
        if (( $# == 2 )); then
            eval $1=\"\$2\"          # Return single value
        else
            eval $1=\(\"\${@:2}\"\)  # Return array
        fi
    fi
}


# Assign variables one scope above the caller
# Usage: local varname [varname ...] && 
#        _upvars [-v varname value] | [-aN varname [value ...]] ...
# Available OPTIONS:
#     -aN  Assign next N values to varname as array
#     -v   Assign single value to varname
# Return: 1 if error occurs
# See: http://fvue.nl/wiki/Bash:_Passing_variables_by_reference
_upvars() {
    if ! (( $# )); then
        echo "${FUNCNAME[0]}: usage: ${FUNCNAME[0]} [-v varname"\
            "value] | [-aN varname [value ...]] ..." 1>&2
        return 2
    fi
    while (( $# )); do
        case $1 in
            -a*)
                # Error checking
                [[ ${1#-a} ]] || { echo "bash: ${FUNCNAME[0]}: \`$1': missing"\
                    "number specifier" 1>&2; return 1; }
                printf %d "${1#-a}" &> /dev/null || { echo "bash:"\
                    "${FUNCNAME[0]}: \`$1': invalid number specifier" 1>&2
                    return 1; }
                # Assign array of -aN elements
                [[ "$2" ]] && unset -v "$2" && eval $2=\(\"\${@:3:${1#-a}}\"\) && 
                shift $((${1#-a} + 2)) || { echo "bash: ${FUNCNAME[0]}:"\
                    "\`$1${2+ }$2': missing argument(s)" 1>&2; return 1; }
                ;;
            -v)
                # Assign single value
                [[ "$2" ]] && unset -v "$2" && eval $2=\"\$3\" &&
                shift 3 || { echo "bash: ${FUNCNAME[0]}: $1: missing"\
                "argument(s)" 1>&2; return 1; }
                ;;
            *)
                echo "bash: ${FUNCNAME[0]}: $1: invalid option" 1>&2
                return 1 ;;
        esac
    done
}


# Reassemble command line words, excluding specified characters from the
# list of word completion separators (COMP_WORDBREAKS).
# @param $1 chars  Characters out of $COMP_WORDBREAKS which should
#     NOT be considered word breaks. This is useful for things like scp where
#     we want to return host:path and not only path, so we would pass the
#     colon (:) as $1 here.
# @param $2 words  Name of variable to return words to
# @param $3 cword  Name of variable to return cword to
#
__reassemble_comp_words_by_ref() {
    local exclude i j ref
    # Exclude word separator characters?
    if [[ $1 ]]; then
        # Yes, exclude word separator characters;
        # Exclude only those characters, which were really included
        exclude="${1//[^$COMP_WORDBREAKS]}"
    fi
        
    # Default to cword unchanged
    eval $3=$COMP_CWORD
    # Are characters excluded which were former included?
    if [[ $exclude ]]; then
        # Yes, list of word completion separators has shrunk;
        # Re-assemble words to complete
        for (( i=0, j=0; i < ${#COMP_WORDS[@]}; i++, j++)); do
            # Is current word not word 0 (the command itself) and is word not
            # empty and is word made up of just word separator characters to be
            # excluded?
            while [[ $i -gt 0 && ${COMP_WORDS[$i]} && 
                ${COMP_WORDS[$i]//[^$exclude]} == ${COMP_WORDS[$i]} 
            ]]; do
                [ $j -ge 2 ] && ((j--))
                # Append word separator to current word
                ref="$2[$j]"
                eval $2[$j]=\${!ref}\${COMP_WORDS[i]}
                # Indicate new cword
                [ $i = $COMP_CWORD ] && eval $3=$j
                # Indicate next word if available, else end *both* while and for loop
                (( $i < ${#COMP_WORDS[@]} - 1)) && ((i++)) || break 2
            done
            # Append word to current word
            ref="$2[$j]"
            eval $2[$j]=\${!ref}\${COMP_WORDS[i]}
            # Indicate new cword
            [[ $i == $COMP_CWORD ]] && eval $3=$j
        done
    else
        # No, list of word completions separators hasn't changed;
        eval $2=\( \"\${COMP_WORDS[@]}\" \)
    fi
} # __reassemble_comp_words_by_ref()


# @param $1 exclude  Characters out of $COMP_WORDBREAKS which should NOT be
#     considered word breaks. This is useful for things like scp where
#     we want to return host:path and not only path, so we would pass the
#     colon (:) as $1 in this case.  Bash-3 doesn't do word splitting, so this
#     ensures we get the same word on both bash-3 and bash-4.
# @param $2 words  Name of variable to return words to
# @param $3 cword  Name of variable to return cword to
# @param $4 cur  Name of variable to return current word to complete to
# @see ___get_cword_at_cursor_by_ref()
__get_cword_at_cursor_by_ref() {
    local cword words=()
    __reassemble_comp_words_by_ref "$1" words cword

    local i cur2
    local cur="$COMP_LINE"
    local index="$COMP_POINT"
    for (( i = 0; i <= cword; ++i )); do
        while [[
            # Current word fits in $cur?
            "${#cur}" -ge ${#words[i]} &&
            # $cur doesn't match cword?
            "${cur:0:${#words[i]}}" != "${words[i]}"
        ]]; do
            # Strip first character
            cur="${cur:1}"
            # Decrease cursor position
            ((index--))
        done

        # Does found word matches cword?
        if [[ "$i" -lt "$cword" ]]; then
            # No, cword lies further;
            local old_size="${#cur}"
            cur="${cur#${words[i]}}"
            local new_size="${#cur}"
            index=$(( index - old_size + new_size ))
        fi
    done

    if [[ "${words[cword]:0:${#cur}}" != "$cur" ]]; then
        # We messed up. At least return the whole word so things keep working
        cur2=${words[cword]}
    else
        cur2=${cur:0:$index}
    fi

    local "$2" "$3" "$4" && 
        _upvars -a${#words[@]} $2 "${words[@]}" -v $3 "$cword" -v $4 "$cur2"
}


# Get the word to complete and optional previous words.
# This is nicer than ${COMP_WORDS[$COMP_CWORD]}, since it handles cases
# where the user is completing in the middle of a word.
# (For example, if the line is "ls foobar",
# and the cursor is here -------->   ^
# Also one is able to cross over possible wordbreak characters.
# Usage: _get_comp_words_by_ref [OPTIONS] [VARNAMES]
# Available VARNAMES:
#     cur         Return cur via $cur
#     prev        Return prev via $prev
#     words       Return words via $words
#     cword       Return cword via $cword
#
# Available OPTIONS:
#     -n EXCLUDE  Characters out of $COMP_WORDBREAKS which should NOT be 
#                 considered word breaks. This is useful for things like scp
#                 where we want to return host:path and not only path, so we
#                 would pass the colon (:) as -n option in this case.  Bash-3
#                 doesn't do word splitting, so this ensures we get the same
#                 word on both bash-3 and bash-4.
#     -c VARNAME  Return cur via $VARNAME
#     -p VARNAME  Return prev via $VARNAME
#     -w VARNAME  Return words via $VARNAME
#     -i VARNAME  Return cword via $VARNAME
#
# Example usage:
#
#    $ _get_comp_words_by_ref -n : cur prev
#
_get_comp_words_by_ref()
{
    local exclude flag i OPTIND=1
    local cur cword words=()
    local upargs=() upvars=() vcur vcword vprev vwords

    while getopts "c:i:n:p:w:" flag "$@"; do
        case $flag in
            c) vcur=$OPTARG ;;
            i) vcword=$OPTARG ;;
            n) exclude=$OPTARG ;;
            p) vprev=$OPTARG ;;
            w) vwords=$OPTARG ;;
        esac
    done
    while [[ $# -ge $OPTIND ]]; do 
        case ${!OPTIND} in
            cur)   vcur=cur ;;
            prev)  vprev=prev ;;
            cword) vcword=cword ;;
            words) vwords=words ;;
            *) echo "bash: $FUNCNAME(): \`${!OPTIND}': unknown argument" \
                1>&2; return 1 ;;
        esac
        let "OPTIND += 1"
    done

    __get_cword_at_cursor_by_ref "$exclude" words cword cur

    [[ $vcur   ]] && { upvars+=("$vcur"  ); upargs+=(-v $vcur   "$cur"  ); }
    [[ $vcword ]] && { upvars+=("$vcword"); upargs+=(-v $vcword "$cword"); }
    [[ $vprev  ]] && { upvars+=("$vprev" ); upargs+=(-v $vprev 
        "${words[cword - 1]}"); }
    [[ $vwords ]] && { upvars+=("$vwords"); upargs+=(-a${#words[@]} $vwords
        "${words[@]}"); }

    (( ${#upvars[@]} )) && local "${upvars[@]}" && _upvars "${upargs[@]}"
}


# Get the word to complete.
# This is nicer than ${COMP_WORDS[$COMP_CWORD]}, since it handles cases
# where the user is completing in the middle of a word.
# (For example, if the line is "ls foobar",
# and the cursor is here -------->   ^
# @param $1 string  Characters out of $COMP_WORDBREAKS which should NOT be
#     considered word breaks. This is useful for things like scp where
#     we want to return host:path and not only path, so we would pass the
#     colon (:) as $1 in this case.  Bash-3 doesn't do word splitting, so this
#     ensures we get the same word on both bash-3 and bash-4.
# @param $2 integer  Index number of word to return, negatively offset to the
#     current word (default is 0, previous is 1), respecting the exclusions
#     given at $1.  For example, `_get_cword "=:" 1' returns the word left of
#     the current word, respecting the exclusions "=:".
# @deprecated  Use `_get_comp_words_by_ref cur' instead
# @see _get_comp_words_by_ref()
_get_cword()
{
    local LC_CTYPE=C
    local cword words
    __reassemble_comp_words_by_ref "$1" words cword

    # return previous word offset by $2
    if [[ ${2//[^0-9]/} ]]; then
        printf "%s" "${words[cword-$2]}"
    elif [[ "${#words[cword]}" -eq 0 || "$COMP_POINT" == "${#COMP_LINE}" ]]; then
        printf "%s" "${words[cword]}"
    else
        local i
        local cur="$COMP_LINE"
        local index="$COMP_POINT"
        for (( i = 0; i <= cword; ++i )); do
            while [[
                # Current word fits in $cur?
                "${#cur}" -ge ${#words[i]} &&
                # $cur doesn't match cword?
                "${cur:0:${#words[i]}}" != "${words[i]}"
            ]]; do
                # Strip first character
                cur="${cur:1}"
                # Decrease cursor position
                ((index--))
            done

            # Does found word matches cword?
            if [[ "$i" -lt "$cword" ]]; then
                # No, cword lies further;
                local old_size="${#cur}"
                cur="${cur#${words[i]}}"
                local new_size="${#cur}"
                index=$(( index - old_size + new_size ))
            fi
        done

        if [[ "${words[cword]:0:${#cur}}" != "$cur" ]]; then
            # We messed up! At least return the whole word so things
            # keep working
            printf "%s" "${words[cword]}"
        else
            printf "%s" "${cur:0:$index}"
        fi
    fi
} # _get_cword()


# Get word previous to the current word.
# This is a good alternative to `prev=${COMP_WORDS[COMP_CWORD-1]}' because bash4
# will properly return the previous word with respect to any given exclusions to
# COMP_WORDBREAKS.
# @deprecated  Use `_get_comp_words_by_ref cur prev' instead
# @see _get_comp_words_by_ref()
#
_get_pword() 
{
    if [ $COMP_CWORD -ge 1 ]; then
        _get_cword "${@:-}" 1;
    fi
}


# If the word-to-complete contains a colon (:), left-trim COMPREPLY items with
# word-to-complete.
# On bash-3, and bash-4 with a colon in COMP_WORDBREAKS, words containing
# colons are always completed as entire words if the word to complete contains
# a colon.  This function fixes this, by removing the colon-containing-prefix
# from COMPREPLY items.
# The preferred solution is to remove the colon (:) from COMP_WORDBREAKS in
# your .bashrc:
#
#    # Remove colon (:) from list of word completion separators
#    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
#
# See also: Bash FAQ - E13) Why does filename completion misbehave if a colon
# appears in the filename? - http://tiswww.case.edu/php/chet/bash/FAQ
# @param $1 current word to complete (cur)
# @modifies global array $COMPREPLY
#
__ltrim_colon_completions() {
    # If word-to-complete contains a colon,
    # and bash-version < 4,
    # or bash-version >= 4 and COMP_WORDBREAKS contains a colon
    if [[
        "$1" == *:* && (
            ${BASH_VERSINFO[0]} -lt 4 || 
            (${BASH_VERSINFO[0]} -ge 4 && "$COMP_WORDBREAKS" == *:*) 
        )
    ]]; then
        # Remove colon-word prefix from COMPREPLY items
        local colon_word=${1%${1##*:}}
        local i=${#COMPREPLY[*]}
        while [ $((--i)) -ge 0 ]; do
            COMPREPLY[$i]=${COMPREPLY[$i]#"$colon_word"}
        done
    fi
} # __ltrim_colon_completions()


# This function quotes the argument in a way so that readline dequoting
# results in the original argument.  This is necessary for at least
# `compgen' which requires its arguments quoted/escaped:
#
#     $ ls "a'b/"
#     c
#     $ compgen -f "a'b/"       # Wrong, doesn't return output
#     $ compgen -f "a\'b/"      # Good (bash-4)
#     a\'b/c
#     $ compgen -f "a\\\\\'b/"  # Good (bash-3)
#     a\'b/c
#
# On bash-3, special characters need to be escaped extra.  This is
# unless the first character is a single quote (').  If the single
# quote appears further down the string, bash default completion also
# fails, e.g.:
#
#     $ ls 'a&b/'
#     f
#     $ foo 'a&b/<TAB>  # Becomes: foo 'a&b/f'
#     $ foo a'&b/<TAB>  # Nothing happens
#
# See also:
# - http://lists.gnu.org/archive/html/bug-bash/2009-03/msg00155.html
# - http://www.mail-archive.com/bash-completion-devel@lists.alioth.\
#   debian.org/msg01944.html
# @param $1  Argument to quote
# @param $2  Name of variable to return result to
_quote_readline_by_ref()
{
    if [[ ${1:0:1} == "'" ]]; then
        if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
            # Leave out first character
            printf -v $2 %s "${1:1}"
        else
            # Quote word, leaving out first character
            printf -v $2 %q "${1:1}"
            # Double-quote word (bash-3)
            printf -v $2 %q ${!2}
        fi
    elif [[ ${BASH_VERSINFO[0]} -le 3 && ${1:0:1} == '"' ]]; then
        printf -v $2 %q "${1:1}"
    else
        printf -v $2 %q "$1"
    fi

    # If result becomes quoted like this: $'string', re-evaluate in order to
    # drop the additional quoting.  See also: http://www.mail-archive.com/
    # bash-completion-devel@lists.alioth.debian.org/msg01942.html
    [[ ${!2:0:1} == '$' ]] && eval $2=${!2}
} # _quote_readline_by_ref()


# This function turns on "-o filenames" behavior dynamically. It is present
# for bash < 4 reasons. See http://bugs.debian.org/272660#64 for info about
# the bash < 4 compgen hack.
_compopt_o_filenames()
{
    # We test for compopt availability first because directly invoking it on
    # bash < 4 at this point may cause terminal echo to be turned off for some
    # reason, see https://bugzilla.redhat.com/653669 for more info.
    type compopt &>/dev/null && compopt -o filenames 2>/dev/null || \
        compgen -f /non-existing-dir/ >/dev/null
}


# This function performs file and directory completion. It's better than
# simply using 'compgen -f', because it honours spaces in filenames.
# @param $1  If `-d', complete only on directories.  Otherwise filter/pick only
#            completions with `.$1' and the uppercase version of it as file
#            extension.
#
_filedir()
{
    local i IFS=$'\n' xspec

    _tilde "$cur" || return 0

    local -a toks
    local quoted tmp

    _quote_readline_by_ref "$cur" quoted
    toks=( ${toks[@]-} $(
        compgen -d -- "$cur" | {
            while read -r tmp; do
                # TODO: I have removed a "[ -n $tmp ] &&" before 'printf ..',
                #       and everything works again. If this bug suddenly
                #       appears again (i.e. "cd /b<TAB>" becomes "cd /"),
                #       remember to check for other similar conditionals (here
                #       and _filedir_xspec()). --David
                printf '%s\n' $tmp
            done
        }
    ))

    if [[ "$1" != -d ]]; then
        # Munge xspec to contain uppercase version too
        [[ ${BASH_VERSINFO[0]} -ge 4 ]] && \
            xspec=${1:+"!*.@($1|${1^^})"} || \
            xspec=${1:+"!*.@($1|$(printf %s $1 | tr '[:lower:]' '[:upper:]'))"}
        toks=( ${toks[@]-} $( compgen -f -X "$xspec" -- $quoted) )
    fi
    [ ${#toks[@]} -ne 0 ] && _compopt_o_filenames

    COMPREPLY=( "${COMPREPLY[@]}" "${toks[@]}" )
} # _filedir()


# This function splits $cur=--foo=bar into $prev=--foo, $cur=bar, making it
# easier to support both "--foo bar" and "--foo=bar" style completions.
# Returns 0 if current option was split, 1 otherwise.
#
_split_longopt()
{
    if [[ "$cur" == --?*=* ]]; then
        # Cut also backslash before '=' in case it ended up there
        # for some reason.
        prev="${cur%%?(\\)=*}"
        cur="${cur#*=}"
        return 0
    fi

    return 1
}

# This function tries to parse the help output of the given command.
# @param $1  command
# @param $2  command options (default: --help)
#
_parse_help() {
    $1 ${2:---help} 2>&1 | sed -e '/^[[:space:]]*-/!d' -e 's|[,/]| |g' | \
        awk '{ print $1; if ($2 ~ /^-/) { print $2 } }' | sed -e 's|[<=].*||'
}

# This function completes on signal names
#
_signals()
{
    local i

    # standard signal completion is rather braindead, so we need
    # to hack around to get what we want here, which is to
    # complete on a dash, followed by the signal name minus
    # the SIG prefix
    COMPREPLY=( $( compgen -A signal SIG${cur#-} ))
    for (( i=0; i < ${#COMPREPLY[@]}; i++ )); do
        COMPREPLY[i]=-${COMPREPLY[i]#SIG}
    done
}

# This function completes on known mac addresses
#
_mac_addresses()
{
    local re='\([A-Fa-f0-9]\{2\}:\)\{5\}[A-Fa-f0-9]\{2\}'
    local PATH="$PATH:/sbin:/usr/sbin"

    # Local interfaces (Linux only?)
    COMPREPLY=( "${COMPREPLY[@]}" $( ifconfig -a 2>/dev/null | sed -ne \
        "s/.*[[:space:]]HWaddr[[:space:]]\{1,\}\($re\)[[:space:]]*$/\1/p" ) )

    # ARP cache
    COMPREPLY=( "${COMPREPLY[@]}" $( arp -an 2>/dev/null | sed -ne \
        "s/.*[[:space:]]\($re\)[[:space:]].*/\1/p" -ne \
        "s/.*[[:space:]]\($re\)[[:space:]]*$/\1/p" ) )

    # /etc/ethers
    COMPREPLY=( "${COMPREPLY[@]}" $( sed -ne \
        "s/^[[:space:]]*\($re\)[[:space:]].*/\1/p" /etc/ethers 2>/dev/null ) )

    COMPREPLY=( $( compgen -W '${COMPREPLY[@]}' -- "$cur" ) )
    __ltrim_colon_completions "$cur"
}

# This function completes on configured network interfaces
#
_configured_interfaces()
{
    if [ -f /etc/debian_version ]; then
        # Debian system
        COMPREPLY=( $( compgen -W "$( sed -ne 's|^iface \([^ ]\{1,\}\).*$|\1|p'\
            /etc/network/interfaces )" -- "$cur" ) )
    elif [ -f /etc/SuSE-release ]; then
        # SuSE system
        COMPREPLY=( $( compgen -W "$( printf '%s\n' \
            /etc/sysconfig/network/ifcfg-* | \
            sed -ne 's|.*ifcfg-\(.*\)|\1|p' )" -- "$cur" ) )
    elif [ -f /etc/pld-release ]; then
        # PLD Linux
        COMPREPLY=( $( compgen -W "$( command ls -B \
            /etc/sysconfig/interfaces | \
            sed -ne 's|.*ifcfg-\(.*\)|\1|p' )" -- "$cur" ) )
    else
        # Assume Red Hat
        COMPREPLY=( $( compgen -W "$( printf '%s\n' \
            /etc/sysconfig/network-scripts/ifcfg-* | \
            sed -ne 's|.*ifcfg-\(.*\)|\1|p' )" -- "$cur" ) )
    fi
}

# This function completes on available kernels
#
_kernel_versions()
{
    COMPREPLY=( $( compgen -W '$( command ls /lib/modules )' -- "$cur" ) )
}

# This function completes on all available network interfaces
# -a: restrict to active interfaces only
# -w: restrict to wireless interfaces only
#
_available_interfaces()
{
    local cmd

    if [ "${1:-}" = -w ]; then
        cmd="iwconfig"
    elif [ "${1:-}" = -a ]; then
        cmd="ifconfig"
    else
        cmd="ifconfig -a"
    fi

    COMPREPLY=( $( eval PATH="$PATH:/sbin" $cmd 2>/dev/null | \
        awk '/^[^ \t]/ { print $1 }' ) )
    COMPREPLY=( $( compgen -W '${COMPREPLY[@]/%[[:punct:]]/}' -- "$cur" ) )
}


# Perform tilde (~) completion
# @return  True (0) if completion needs further processing, 
#          False (> 0) if tilde is followed by a valid username, completions
#          are put in COMPREPLY and no further processing is necessary.
_tilde() {
    local result=0
    # Does $1 start with tilde (~) and doesn't contain slash (/)?
    if [[ ${1:0:1} == "~" && $1 == ${1//\/} ]]; then
        _compopt_o_filenames
        # Try generate username completions
        COMPREPLY=( $( compgen -P '~' -u "${1#\~}" ) )
        result=${#COMPREPLY[@]}
    fi
    return $result
}


# Expand variable starting with tilde (~)
# We want to expand ~foo/... to /home/foo/... to avoid problems when
# word-to-complete starting with a tilde is fed to commands and ending up
# quoted instead of expanded.
# Only the first portion of the variable from the tilde up to the first slash
# (~../) is expanded.  The remainder of the variable, containing for example
# a dollar sign variable ($) or asterisk (*) is not expanded.
# Example usage:
#
#    $ v="~"; __expand_tilde_by_ref v; echo "$v"
#
# Example output:
#
#       v                  output
#    --------         ----------------
#    ~                /home/user
#    ~foo/bar         /home/foo/bar
#    ~foo/$HOME       /home/foo/$HOME
#    ~foo/a  b        /home/foo/a  b
#    ~foo/*           /home/foo/*
#  
# @param $1  Name of variable (not the value of the variable) to expand
__expand_tilde_by_ref() {
    # Does $1 start with tilde (~)?
    if [ "${!1:0:1}" = "~" ]; then
        # Does $1 contain slash (/)?
        if [ "${!1}" != "${!1//\/}" ]; then
            # Yes, $1 contains slash;
            # 1: Remove * including and after first slash (/), i.e. "~a/b"
            #    becomes "~a".  Double quotes allow eval.
            # 2: Remove * before the first slash (/), i.e. "~a/b"
            #    becomes "b".  Single quotes prevent eval.
            #       +-----1----+ +---2----+
            eval $1="${!1/%\/*}"/'${!1#*/}'
        else 
            # No, $1 doesn't contain slash
            eval $1="${!1}"
        fi
    fi
} # __expand_tilde_by_ref()


# This function expands tildes in pathnames
#
_expand()
{
    # FIXME: Why was this here?
    #[ "$cur" != "${cur%\\}" ] && cur="$cur\\"

    # Expand ~username type directory specifications.  We want to expand
    # ~foo/... to /home/foo/... to avoid problems when $cur starting with
    # a tilde is fed to commands and ending up quoted instead of expanded.

    if [[ "$cur" == \~*/* ]]; then
        eval cur=$cur
    elif [[ "$cur" == \~* ]]; then
        cur=${cur#\~}
        COMPREPLY=( $( compgen -P '~' -u "$cur" ) )
        [ ${#COMPREPLY[@]} -eq 1 ] && eval COMPREPLY[0]=${COMPREPLY[0]}
        return ${#COMPREPLY[@]}
    fi
}

# This function completes on process IDs.
# AIX and Solaris ps prefers X/Open syntax.
[[ $UNAME == SunOS || $UNAME == AIX ]] &&
_pids()
{
    COMPREPLY=( $( compgen -W '$( command ps -efo pid | sed 1d )' -- "$cur" ))
} ||
_pids()
{
    COMPREPLY=( $( compgen -W '$( command ps axo pid= )' -- "$cur" ) )
}

# This function completes on process group IDs.
# AIX and SunOS prefer X/Open, all else should be BSD.
[[ $UNAME == SunOS || $UNAME == AIX ]] &&
_pgids()
{
    COMPREPLY=( $( compgen -W '$( command ps -efo pgid | sed 1d )' -- "$cur" ))
} ||
_pgids()
{
    COMPREPLY=( $( compgen -W '$( command ps axo pgid= )' -- "$cur" ))
}

# This function completes on process names.
# AIX and SunOS prefer X/Open, all else should be BSD.
[[ $UNAME == SunOS || $UNAME == AIX ]] &&
_pnames()
{
    COMPREPLY=( $( compgen -X '<defunct>' -W '$( command ps -efo comm | \
        sed -e 1d -e "s:.*/::" -e "s/^-//" | sort -u )' -- "$cur" ) )
} ||
_pnames()
{
    # FIXME: completes "[kblockd/0]" to "0". Previously it was completed
    # to "kblockd" which isn't correct either. "kblockd/0" would be
    # arguably most correct, but killall from psmisc 22 treats arguments
    # containing "/" specially unless -r is given so that wouldn't quite
    # work either. Perhaps it'd be best to not complete these to anything
    # for now.
    # Not using "ps axo comm" because under some Linux kernels, it
    # truncates command names (see e.g. http://bugs.debian.org/497540#19)
    COMPREPLY=( $( compgen -X '<defunct>' -W '$( command ps axo command= | \
        sed -e "s/ .*//" -e "s:.*/::" -e "s/:$//" -e "s/^[[(-]//" \
            -e "s/[])]$//" | sort -u )' -- "$cur" ) )
}

# This function completes on user IDs
#
_uids()
{
    if type getent &>/dev/null; then
        COMPREPLY=( $( compgen -W '$( getent passwd | cut -d: -f3 )' -- "$cur" ) )
    elif type perl &>/dev/null; then
        COMPREPLY=( $( compgen -W '$( perl -e '"'"'while (($uid) = (getpwent)[2]) { print $uid . "\n" }'"'"' )' -- "$cur" ) )
    else
        # make do with /etc/passwd
        COMPREPLY=( $( compgen -W '$( cut -d: -f3 /etc/passwd )' -- "$cur" ) )
    fi
}

# This function completes on group IDs
#
_gids()
{
    if type getent &>/dev/null; then
        COMPREPLY=( $( compgen -W '$( getent group | cut -d: -f3 )' \
            -- "$cur" ) )
    elif type perl &>/dev/null; then
        COMPREPLY=( $( compgen -W '$( perl -e '"'"'while (($gid) = (getgrent)[2]) { print $gid . "\n" }'"'"' )' -- "$cur" ) )
    else
        # make do with /etc/group
        COMPREPLY=( $( compgen -W '$( cut -d: -f3 /etc/group )' -- "$cur" ) )
    fi
}

# This function completes on services
#
_services()
{
    local sysvdir famdir
    [ -d /etc/rc.d/init.d ] && sysvdir=/etc/rc.d/init.d || sysvdir=/etc/init.d
    famdir=/etc/xinetd.d
    COMPREPLY=( $( printf '%s\n' \
        $sysvdir/!(*.rpm@(orig|new|save)|*~|functions) ) )

    if [ -d $famdir ]; then
        COMPREPLY=( "${COMPREPLY[@]}" $( printf '%s\n' \
            $famdir/!(*.rpm@(orig|new|save)|*~) ) )
    fi

    COMPREPLY=( $( compgen -W '${COMPREPLY[@]#@($sysvdir|$famdir)/}' -- "$cur" ) )
}

# This function completes on modules
#
_modules()
{
    local modpath
    modpath=/lib/modules/$1
    COMPREPLY=( $( compgen -W "$( command ls -R $modpath | \
        sed -ne 's/^\(.*\)\.k\{0,1\}o\(\.gz\)\{0,1\}$/\1/p' )" -- "$cur" ) )
}

# This function completes on installed modules
#
_installed_modules()
{
    COMPREPLY=( $( compgen -W "$( PATH="$PATH:/sbin" lsmod | \
        awk '{if (NR != 1) print $1}' )" -- "$1" ) )
}

# This function completes on user or user:group format; as for chown and cpio.
#
# The : must be added manually; it will only complete usernames initially.
# The legacy user.group format is not supported.
#
# @param $1  If -u, only return users/groups the user has access to in
#            context of current completion.
_usergroup()
{
    if [[ $cur = *\\\\* || $cur = *:*:* ]]; then
        # Give up early on if something seems horribly wrong.
        return
    elif [[ $cur = *\\:* ]]; then
        # Completing group after 'user\:gr<TAB>'.
        # Reply with a list of groups prefixed with 'user:', readline will
        # escape to the colon.
        local prefix
        prefix=${cur%%*([^:])}
        prefix=${prefix//\\}
        local mycur="${cur#*[:]}"
        if [[ $1 == -u ]]; then
            _allowed_groups "$mycur"
        else
            local IFS=$'\n'
            COMPREPLY=( $( compgen -g -- "$mycur" ) )
        fi
        COMPREPLY=( $( compgen -P "$prefix" -W "${COMPREPLY[@]}" ) )
    elif [[ $cur = *:* ]]; then
        # Completing group after 'user:gr<TAB>'.
        # Reply with a list of unprefixed groups since readline with split on :
        # and only replace the 'gr' part
        local mycur="${cur#*:}"
        if [[ $1 == -u ]]; then
            _allowed_groups "$mycur"
        else
            local IFS=$'\n'
            COMPREPLY=( $( compgen -g -- "$mycur" ) )
        fi
    else
        # Completing a partial 'usernam<TAB>'.
        #
        # Don't suffix with a : because readline will escape it and add a
        # slash. It's better to complete into 'chown username ' than 'chown
        # username\:'.
        if [[ $1 == -u ]]; then
            _allowed_users "$cur"
        else
            local IFS=$'\n'
            COMPREPLY=( $( compgen -u -- "$cur" ) )
        fi
    fi
}

_allowed_users()
{
    if _complete_as_root; then
        local IFS=$'\n'
        COMPREPLY=( $( compgen -u -- "${1:-$cur}" ) )
    else
        local IFS=$'\n '
        COMPREPLY=( $( compgen -W \
            "$( id -un 2>/dev/null || whoami 2>/dev/null )" -- "${1:-$cur}" ) )
    fi
}

_allowed_groups()
{
    if _complete_as_root; then
        local IFS=$'\n'
        COMPREPLY=( $( compgen -g -- "$1" ) )
    else
        local IFS=$'\n '
        COMPREPLY=( $( compgen -W \
            "$( id -Gn 2>/dev/null || groups 2>/dev/null )" -- "$1" ) )
    fi
}

# This function completes on valid shells
#
_shells()
{
    COMPREPLY=( "${COMPREPLY[@]}" $( compgen -W \
        '$( command grep "^[[:space:]]*/" /etc/shells 2>/dev/null )' \
        -- "$cur" ) )
}

# This function completes on valid filesystem types
#
_fstypes()
{
    local fss

    if [ -e /proc/filesystems ] ; then
        # Linux
        fss="$( cut -d$'\t' -f2 /proc/filesystems )
             $( awk '! /\*/ { print $NF }' /etc/filesystems 2>/dev/null )"
    else
        # Generic
        fss="$( awk '/^[ \t]*[^#]/ { print $3 }' /etc/fstab 2>/dev/null )
             $( awk '/^[ \t]*[^#]/ { print $3 }' /etc/mnttab 2>/dev/null )
             $( awk '/^[ \t]*[^#]/ { print $4 }' /etc/vfstab 2>/dev/null )
             $( awk '{ print $1 }' /etc/dfs/fstypes 2>/dev/null )
             $( [ -d /etc/fs ] && command ls /etc/fs )"
    fi

    [ -n "$fss" ] && \
        COMPREPLY=( "${COMPREPLY[@]}" $( compgen -W "$fss" -- "$cur" ) )
}

# Get real command.
# - arg: $1  Command
# - stdout:  Filename of command in PATH with possible symbolic links resolved.
#            Empty string if command not found.
# - return:  True (0) if command found, False (> 0) if not.
_realcommand()
{
    type -P "$1" > /dev/null && {
        if type -p realpath > /dev/null; then
            realpath "$(type -P "$1")"
        elif type -p readlink > /dev/null; then
            readlink "$(type -P "$1")"
        else
            type -P "$1"
        fi
    }
}

# This function returns the first arugment, excluding options
# @param $1 chars  Characters out of $COMP_WORDBREAKS which should
#     NOT be considered word breaks. See __reassemble_comp_words_by_ref.
_get_first_arg()
{
    local i

    arg=
    for (( i=1; i < COMP_CWORD; i++ )); do
        if [[ "${COMP_WORDS[i]}" != -* ]]; then
            arg=${COMP_WORDS[i]}
            break
        fi
    done
}


# This function counts the number of args, excluding options
# @param $1 chars  Characters out of $COMP_WORDBREAKS which should
#     NOT be considered word breaks. See __reassemble_comp_words_by_ref.
_count_args()
{
    local i cword words
    __reassemble_comp_words_by_ref "$1" words cword

    args=1
    for i in "${words[@]:1:cword-1}"; do
        [[ "$i" != -* ]] && args=$(($args+1))
    done
}

# This function completes on PCI IDs
#
_pci_ids()
{
    COMPREPLY=( ${COMPREPLY[@]:-} $( compgen -W \
        "$( PATH="$PATH:/sbin" lspci -n | awk '{print $3}')" -- "$cur" ) )
}

# This function completes on USB IDs
#
_usb_ids()
{
    COMPREPLY=( ${COMPREPLY[@]:-} $( compgen -W \
        "$( PATH="$PATH:/sbin" lsusb | awk '{print $6}' )" -- "$cur" ) )
}

# CD device names
_cd_devices()
{
    COMPREPLY=( "${COMPREPLY[@]}"
        $( compgen -f -d -X "!*/?([amrs])cd*" -- "${cur:-/dev/}" ) )
}

# DVD device names
_dvd_devices()
{
    COMPREPLY=( "${COMPREPLY[@]}"
        $( compgen -f -d -X "!*/?(r)dvd*" -- "${cur:-/dev/}" ) )
}

# start of section containing completion functions for external programs

# a little help for FreeBSD ports users
[ $UNAME = FreeBSD ] && complete -W 'index search fetch fetch-list extract \
    patch configure build install reinstall deinstall clean clean-depends \
    kernel buildworld' make

# This function provides simple user@host completion
#
_user_at_host() {
    local cur

    COMPREPLY=()
    _get_comp_words_by_ref -n : cur

    if [[ $cur == *@* ]]; then
        _known_hosts_real "$cur"
    else
        COMPREPLY=( $( compgen -u -- "$cur" ) )
    fi

    return 0
}
shopt -u hostcomplete && complete -F _user_at_host -o nospace talk ytalk finger

# NOTE: Using this function as a helper function is deprecated.  Use
#       `_known_hosts_real' instead.
_known_hosts()
{
    local options
    COMPREPLY=()

    # NOTE: Using `_known_hosts' as a helper function and passing options
    #       to `_known_hosts' is deprecated: Use `_known_hosts_real' instead.
    [[ "$1" == -a || "$2" == -a ]] && options=-a
    [[ "$1" == -c || "$2" == -c ]] && options="$options -c"
    _known_hosts_real $options "$(_get_cword :)"
} # _known_hosts()

# Helper function for completing _known_hosts.
# This function performs host completion based on ssh's config and known_hosts
# files, as well as hostnames reported by avahi-browse if
# COMP_KNOWN_HOSTS_WITH_AVAHI is set to a non-empty value.  Also hosts from
# HOSTFILE (compgen -A hostname) are added, unless
# COMP_KNOWN_HOSTS_WITH_HOSTFILE is set to an empty value.
# Usage: _known_hosts_real [OPTIONS] CWORD
# Options:  -a             Use aliases
#           -c             Use `:' suffix
#           -F configfile  Use `configfile' for configuration settings
#           -p PREFIX      Use PREFIX
# Return: Completions, starting with CWORD, are added to COMPREPLY[]
_known_hosts_real()
{
    local configfile flag prefix
    local cur curd awkcur user suffix aliases i host
    local -a kh khd config

    local OPTIND=1
    while getopts "acF:p:" flag "$@"; do
        case $flag in
            a) aliases='yes' ;;
            c) suffix=':' ;;
            F) configfile=$OPTARG ;;
            p) prefix=$OPTARG ;;
        esac
    done
    [ $# -lt $OPTIND ] && echo "error: $FUNCNAME: missing mandatory argument CWORD"
    cur=${!OPTIND}; let "OPTIND += 1"
    [ $# -ge $OPTIND ] && echo "error: $FUNCNAME("$@"): unprocessed arguments:"\
    $(while [ $# -ge $OPTIND ]; do printf '%s\n' ${!OPTIND}; shift; done)

    [[ $cur == *@* ]] && user=${cur%@*}@ && cur=${cur#*@}
    kh=()

    # ssh config files
    if [ -n "$configfile" ]; then
        [ -r "$configfile" ] &&
        config=( "${config[@]}" "$configfile" )
    else
        for i in /etc/ssh/ssh_config "${HOME}/.ssh/config" \
            "${HOME}/.ssh2/config"; do
            [ -r $i ] && config=( "${config[@]}" "$i" )
        done
    fi

    # Known hosts files from configs
    if [ ${#config[@]} -gt 0 ]; then
        local OIFS=$IFS IFS=$'\n'
        local -a tmpkh
        # expand paths (if present) to global and user known hosts files
        # TODO(?): try to make known hosts files with more than one consecutive
        #          spaces in their name work (watch out for ~ expansion
        #          breakage! Alioth#311595)
        tmpkh=( $( awk 'sub("^[ \t]*([Gg][Ll][Oo][Bb][Aa][Ll]|[Uu][Ss][Ee][Rr])[Kk][Nn][Oo][Ww][Nn][Hh][Oo][Ss][Tt][Ss][Ff][Ii][Ll][Ee][ \t]+", "") { print $0 }' "${config[@]}" | sort -u ) )
        for i in "${tmpkh[@]}"; do
            # Remove possible quotes
            i=${i//\"}
            # Eval/expand possible `~' or `~user'
            __expand_tilde_by_ref i
            [ -r "$i" ] && kh=( "${kh[@]}" "$i" )
        done
        IFS=$OIFS
    fi

    if [ -z "$configfile" ]; then
        # Global and user known_hosts files
        for i in /etc/ssh/ssh_known_hosts /etc/ssh/ssh_known_hosts2 \
            /etc/known_hosts /etc/known_hosts2 ~/.ssh/known_hosts \
            ~/.ssh/known_hosts2; do
            [ -r $i ] && kh=( "${kh[@]}" $i )
        done
        for i in /etc/ssh2/knownhosts ~/.ssh2/hostkeys; do
            [ -d $i ] && khd=( "${khd[@]}" $i/*pub )
        done
    fi

    # If we have known_hosts files to use
    if [[ ${#kh[@]} -gt 0 || ${#khd[@]} -gt 0 ]]; then
        # Escape slashes and dots in paths for awk
        awkcur=${cur//\//\\\/}
        awkcur=${awkcur//\./\\\.}
        curd=$awkcur

        if [[ "$awkcur" == [0-9]*[.:]* ]]; then
            # Digits followed by a dot or a colon - just search for that
            awkcur="^$awkcur[.:]*"
        elif [[ "$awkcur" == [0-9]* ]]; then
            # Digits followed by no dot or colon - search for digits followed
            # by a dot or a colon
            awkcur="^$awkcur.*[.:]"
        elif [ -z "$awkcur" ]; then
            # A blank - search for a dot, a colon, or an alpha character
            awkcur="[a-z.:]"
        else
            awkcur="^$awkcur"
        fi

        if [ ${#kh[@]} -gt 0 ]; then
            # FS needs to look for a comma separated list
            COMPREPLY=( "${COMPREPLY[@]}" $( awk 'BEGIN {FS=","}
            /^\s*[^|\#]/ {for (i=1; i<=2; ++i) { \
            sub(" .*$", "", $i); \
            sub("^\\[", "", $i); sub("\\](:[0-9]+)?$", "", $i); \
            if ($i ~ /'"$awkcur"'/) {print $i} \
            }}' "${kh[@]}" 2>/dev/null ) )
        fi
        if [ ${#khd[@]} -gt 0 ]; then
            # Needs to look for files called
            # .../.ssh2/key_22_<hostname>.pub
            # dont fork any processes, because in a cluster environment,
            # there can be hundreds of hostkeys
            for i in "${khd[@]}" ; do
                if [[ "$i" == *key_22_$curd*.pub && -r "$i" ]]; then
                    host=${i/#*key_22_/}
                    host=${host/%.pub/}
                    COMPREPLY=( "${COMPREPLY[@]}" $host )
                fi
            done
        fi

        # apply suffix and prefix
        for (( i=0; i < ${#COMPREPLY[@]}; i++ )); do
            COMPREPLY[i]=$prefix$user${COMPREPLY[i]}$suffix
        done
    fi

    # append any available aliases from config files
    if [[ ${#config[@]} -gt 0 && -n "$aliases" ]]; then
        local hosts=$( sed -ne 's/^[[:blank:]]*[Hh][Oo][Ss][Tt]\([Nn][Aa][Mm][Ee]\)\{0,1\}[[:blank:]]\{1,\}\([^#*?]*\)\(#.*\)\{0,1\}$/\2/p' "${config[@]}" )
        COMPREPLY=( "${COMPREPLY[@]}" $( compgen  -P "$prefix$user" \
            -S "$suffix" -W "$hosts" -- "$cur" ) )
    fi

    # Add hosts reported by avahi-browse, if desired and it's available.
    if [[ ${COMP_KNOWN_HOSTS_WITH_AVAHI:-} ]] && \
        type avahi-browse &>/dev/null; then
        # The original call to avahi-browse also had "-k", to avoid lookups
        # into avahi's services DB. We don't need the name of the service, and
        # if it contains ";", it may mistify the result. But on Gentoo (at
        # least), -k wasn't available (even if mentioned in the manpage) some
        # time ago, so...
        COMPREPLY=( "${COMPREPLY[@]}" $( \
            compgen -P "$prefix$user" -S "$suffix" -W \
            "$( avahi-browse -cpr _workstation._tcp 2>/dev/null | \
                 awk -F';' '/^=/ { print $7 }' | sort -u )" -- "$cur" ) )
    fi

    # Add results of normal hostname completion, unless
    # `COMP_KNOWN_HOSTS_WITH_HOSTFILE' is set to an empty value.
    if [ -n "${COMP_KNOWN_HOSTS_WITH_HOSTFILE-1}" ]; then
        COMPREPLY=( "${COMPREPLY[@]}"
            $( compgen -A hostname -P "$prefix$user" -S "$suffix" -- "$cur" ) )
    fi

    __ltrim_colon_completions "$prefix$user$cur"

    return 0
} # _known_hosts_real()
complete -F _known_hosts traceroute traceroute6 tracepath tracepath6 ping \
    ping6 fping fping6 telnet host nslookup rsh rlogin ftp dig mtr \
    ssh-installkeys showmount

# This meta-cd function observes the CDPATH variable, so that cd additionally
# completes on directories under those specified in CDPATH.
#
_cd()
{
    local cur IFS=$'\n' i j k
    _get_comp_words_by_ref cur

    # try to allow variable completion
    if [[ "$cur" == ?(\\)\$* ]]; then
        COMPREPLY=( $( compgen -v -P '$' -- "${cur#?(\\)$}" ) )
        return 0
    fi

    _compopt_o_filenames

    # Use standard dir completion if no CDPATH or parameter starts with /,
    # ./ or ../
    if [[ -z "${CDPATH:-}" || "$cur" == ?(.)?(.)/* ]]; then
        _filedir -d
        return 0
    fi

    local -r mark_dirs=$(_rl_enabled mark-directories && echo y)
    local -r mark_symdirs=$(_rl_enabled mark-symlinked-directories && echo y)

    # we have a CDPATH, so loop on its contents
    for i in ${CDPATH//:/$'\n'}; do
        # create an array of matched subdirs
        k="${#COMPREPLY[@]}"
        for j in $( compgen -d $i/$cur ); do
            if [[ ( $mark_symdirs && -h $j || $mark_dirs && ! -h $j ) && ! -d ${j#$i/} ]]; then
                j="${j}/"
            fi
            COMPREPLY[k++]=${j#$i/}
        done
    done

    _filedir -d

    if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
        i=${COMPREPLY[0]}
        if [[ "$i" == "$cur" && $i != "*/" ]]; then
            COMPREPLY[0]="${i}/"
        fi
    fi

    return 0
}
if shopt -q cdable_vars; then
    complete -v -F _cd -o nospace cd
else
    complete -F _cd -o nospace cd
fi

# a wrapper method for the next one, when the offset is unknown
_command()
{
    local offset i

    # find actual offset, as position of the first non-option
    offset=1
    for (( i=1; i <= COMP_CWORD; i++ )); do
        if [[ "${COMP_WORDS[i]}" != -* ]]; then
            offset=$i
            break
        fi
    done
    _command_offset $offset
}

# A meta-command completion function for commands like sudo(8), which need to
# first complete on a command, then complete according to that command's own
# completion definition - currently not quite foolproof (e.g. mount and umount
# don't work properly), but still quite useful.
#
_command_offset()
{
    local cur func cline cspec noglob cmd i char_offset word_offset \
        _COMMAND_FUNC _COMMAND_FUNC_ARGS

    word_offset=$1

    # rewrite current completion context before invoking
    # actual command completion

    # find new first word position, then
    # rewrite COMP_LINE and adjust COMP_POINT
    local first_word=${COMP_WORDS[$word_offset]}
    for (( i=0; i <= ${#COMP_LINE}; i++ )); do
        if [[ "${COMP_LINE:$i:${#first_word}}" == "$first_word" ]]; then
            char_offset=$i
            break
        fi
    done
    COMP_LINE=${COMP_LINE:$char_offset}
    COMP_POINT=$(( COMP_POINT - $char_offset ))

    # shift COMP_WORDS elements and adjust COMP_CWORD
    for (( i=0; i <= COMP_CWORD - $word_offset; i++ )); do
        COMP_WORDS[i]=${COMP_WORDS[i+$word_offset]}
    done
    for (( i; i <= COMP_CWORD; i++ )); do
        unset COMP_WORDS[i];
    done
    COMP_CWORD=$(( $COMP_CWORD - $word_offset ))

    COMPREPLY=()
    _get_comp_words_by_ref cur

    if [[ $COMP_CWORD -eq 0 ]]; then
        _compopt_o_filenames
        COMPREPLY=( $( compgen -c -- "$cur" ) )
    else
        cmd=${COMP_WORDS[0]}
        if complete -p ${cmd##*/} &>/dev/null; then
            cspec=$( complete -p ${cmd##*/} )
            if [ "${cspec#* -F }" != "$cspec" ]; then
                # complete -F <function>

                # get function name
                func=${cspec#*-F }
                func=${func%% *}

                if [[ ${#COMP_WORDS[@]} -ge 2 ]]; then
                    $func $cmd "${COMP_WORDS[${#COMP_WORDS[@]}-1]}" "${COMP_WORDS[${#COMP_WORDS[@]}-2]}"
                else
                    $func $cmd "${COMP_WORDS[${#COMP_WORDS[@]}-1]}"
                fi

                # remove any \: generated by a command that doesn't
                # default to filenames or dirnames (e.g. sudo chown)
                # FIXME: I'm pretty sure this does not work!
                if [ "${cspec#*-o }" != "$cspec" ]; then
                    cspec=${cspec#*-o }
                    cspec=${cspec%% *}
                    if [[ "$cspec" != @(dir|file)names ]]; then
                        COMPREPLY=("${COMPREPLY[@]//\\\\:/:}")
                    else
                        _compopt_o_filenames
                    fi
                fi
            elif [ -n "$cspec" ]; then
                cspec=${cspec#complete};
                cspec=${cspec%%${cmd##*/}};
                COMPREPLY=( $( eval compgen "$cspec" -- "$cur" ) );
            fi
        elif [ ${#COMPREPLY[@]} -eq 0 ]; then
            _filedir
        fi
    fi
}
complete -F _command aoss command do else eval exec ltrace nice nohup padsp \
    then time tsocks vsound xargs

_root_command()
{
    local PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin
    local root_command=$1
    _command $1 $2 $3
}
complete -F _root_command fakeroot gksu gksudo kdesudo really sudo

# Return true if the completion should be treated as running as root
_complete_as_root()
{
    [[ $EUID -eq 0 || ${root_command:-} ]]
}

_longopt()
{
    local cur prev split=false
    _get_comp_words_by_ref -n = cur prev

    _split_longopt && split=true

    case "$prev" in
        --*[Dd][Ii][Rr]*)
            _filedir -d
            return 0
            ;;
        --*[Ff][Ii][Ll][Ee]*|--*[Pp][Aa][Tt][Hh]*)
            _filedir
            return 0
            ;;
    esac

    $split && return 0

    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $( compgen -W "$( $1 --help 2>&1 | \
            sed -ne 's/.*\(--[-A-Za-z0-9]\{1,\}\).*/\1/p' | sort -u )" \
            -- "$cur" ) )
    elif [[ "$1" == @(mk|rm)dir ]]; then
        _filedir -d
    else
        _filedir
    fi
}
# makeinfo and texi2dvi are defined elsewhere.
for i in a2ps awk bash bc bison cat colordiff cp csplit \
    curl cut date df diff dir du enscript env expand fmt fold gperf gprof \
    grep grub head indent irb ld ldd less ln ls m4 md5sum mkdir mkfifo mknod \
    mv netstat nl nm objcopy objdump od paste patch pr ptx readelf rm rmdir \
    sed seq sha{,1,224,256,384,512}sum shar sort split strip tac tail tee \
    texindex touch tr uname unexpand uniq units vdir wc wget who; do
    have $i && complete -F _longopt -o default $i
done
unset i

_filedir_xspec()
{
    local IFS cur xspec

    IFS=$'\n'
    COMPREPLY=()
    _get_comp_words_by_ref cur

    _expand || return 0

    # get first exclusion compspec that matches this command
    xspec=$( awk "/^complete[ \t]+.*[ \t]${1##*/}([ \t]|\$)/ { print \$0; exit }" \
        "$BASH_COMPLETION" )
    # prune to leave nothing but the -X spec
    xspec=${xspec#*-X }
    xspec=${xspec%% *}

    local -a toks
    local tmp

    toks=( ${toks[@]-} $(
        compgen -d -- "$(quote_readline "$cur")" | {
        while read -r tmp; do
            # see long TODO comment in _filedir() --David
            printf '%s\n' $tmp
        done
        }
        ))

    # Munge xspec to contain uppercase version too
    eval xspec="${xspec}"
    local matchop=!
    if [[ $xspec == !* ]]; then
        xspec=${xspec#!}
        matchop=@
    fi
    [[ ${BASH_VERSINFO[0]} -ge 4 ]] && \
        xspec="$matchop($xspec|${xspec^^})" || \
        xspec="$matchop($xspec|$(printf %s $xspec | tr '[:lower:]' '[:upper:]'))"

    toks=( ${toks[@]-} $(
        eval compgen -f -X "!$xspec" -- "\$(quote_readline "\$cur")" | {
        while read -r tmp; do
            [ -n $tmp ] && printf '%s\n' $tmp
        done
        }
        ))

    [ ${#toks[@]} -ne 0 ] && _compopt_o_filenames
    COMPREPLY=( "${toks[@]}" )
}
list=( $( sed -ne '/^# START exclude/,/^# FINISH exclude/p' "$BASH_COMPLETION" | \
    # read exclusion compspecs
    (
    while read line
    do
        # ignore compspecs that are commented out
        if [ "${line#\#}" != "$line" ]; then continue; fi
        line=${line%# START exclude*}
        line=${line%# FINISH exclude*}
        line=${line##*\'}
        list=( "${list[@]}" $line )
    done
    printf '%s ' "${list[@]}"
    )
    ) )
# remove previous compspecs
if [ ${#list[@]} -gt 0 ]; then
    eval complete -r ${list[@]}
    # install new compspecs
    eval complete -F _filedir_xspec "${list[@]}"
fi
unset list

# source completion directory definitions
if [[ -d $BASH_COMPLETION_COMPAT_DIR && -r $BASH_COMPLETION_COMPAT_DIR && \
    -x $BASH_COMPLETION_COMPAT_DIR ]]; then
    for i in $(LC_ALL=C command ls "$BASH_COMPLETION_COMPAT_DIR"); do
        i=$BASH_COMPLETION_COMPAT_DIR/$i
        [[ ${i##*/} != @(*~|*.bak|*.swp|\#*\#|*.dpkg*|*.rpm@(orig|new|save)|Makefile*) \
            && -f $i && -r $i ]] && . "$i"
    done
fi
if [[ $BASH_COMPLETION_DIR != $BASH_COMPLETION_COMPAT_DIR && \
    -d $BASH_COMPLETION_DIR && -r $BASH_COMPLETION_DIR && \
    -x $BASH_COMPLETION_DIR ]]; then
    for i in $(LC_ALL=C command ls "$BASH_COMPLETION_DIR"); do
        i=$BASH_COMPLETION_DIR/$i
        [[ ${i##*/} != @(*~|*.bak|*.swp|\#*\#|*.dpkg*|*.rpm@(orig|new|save)|Makefile*) \
            && -f $i && -r $i ]] && . "$i"
    done
fi
unset i

# source user completion file
[[ $BASH_COMPLETION != ~/.bash_completion && -r ~/.bash_completion ]] \
    && . ~/.bash_completion
unset -f have
unset UNAME USERLAND have

set $BASH_COMPLETION_ORIGINAL_V_VALUE
unset BASH_COMPLETION_ORIGINAL_V_VALUE

# Local variables:
# mode: shell-script
# sh-basic-offset: 4
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: ts=4 sw=4 et filetype=sh


# We shouldn't rely on the user's grep settings to be correct. If we set these
# here anytime asdf invokes grep it will be invoked with these options
# shellcheck disable=SC2034
GREP_OPTIONS="--color=never"
# shellcheck disable=SC2034
GREP_COLORS=

ASDF_DIR=${ASDF_DIR:-''}

asdf_version() {
  local version git_rev
  version="$(cat "$(asdf_dir)/VERSION")"
  if [ -d "$(asdf_dir)/.git" ]; then
    git_rev="$(git --git-dir "$(asdf_dir)/.git" rev-parse --short HEAD)"
    echo "${version}-${git_rev}"
  else
    echo "${version}"
  fi
}

asdf_dir() {
  if [ -z "$ASDF_DIR" ]; then
    local current_script_path=${BASH_SOURCE[0]}
    export ASDF_DIR
    ASDF_DIR=$(
      cd "$(dirname "$(dirname "$current_script_path")")" || exit
      pwd
    )
  fi

  echo "$ASDF_DIR"
}

asdf_repository_url() {
  echo "https://github.com/asdf-vm/asdf-plugins.git"
}

asdf_data_dir() {
  local data_dir

  if [ -n "${ASDF_DATA_DIR}" ]; then
    data_dir="${ASDF_DATA_DIR}"
  elif [[ $EUID -ne 0 ]]; then
    data_dir="$HOME/.asdf"
  else
    data_dir="$(asdf_dir)"
  fi

  echo "$data_dir"
}

get_install_path() {
  local plugin=$1
  local install_type=$2
  local version=$3

  local install_dir
  install_dir="$(asdf_data_dir)/installs"

  mkdir -p "${install_dir}/${plugin}"

  if [ "$install_type" = "version" ]; then
    echo "${install_dir}/${plugin}/${version}"
  else
    echo "${install_dir}/${plugin}/${install_type}-${version}"
  fi
}

list_installed_versions() {
  local plugin_name=$1
  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")

  local plugin_installs_path
  plugin_installs_path="$(asdf_data_dir)/installs/${plugin_name}"

  if [ -d "$plugin_installs_path" ]; then
    for install in "${plugin_installs_path}"/*/; do
      [[ -e "$install" ]] || break
      basename "$install" | sed 's/^ref-/ref:/'
    done
  fi
}

check_if_plugin_exists() {
  local plugin_name=$1

  # Check if we have a non-empty argument
  if [ -z "${1}" ]; then
    display_error "No plugin given"
    exit 1
  fi

  if [ ! -d "$(asdf_data_dir)/plugins/$plugin_name" ]; then
    display_error "No such plugin: $plugin_name"
    exit 1
  fi
}

check_if_version_exists() {
  local plugin_name=$1
  local version=$2

  check_if_plugin_exists "$plugin_name"

  local install_path
  install_path=$(find_install_path "$plugin_name" "$version")

  if [ "$version" != "system" ] && [ ! -d "$install_path" ]; then
    display_error "version $version is not installed for $plugin_name"
    exit 1
  fi
}

get_plugin_path() {
  if test -n "$1"; then
    echo "$(asdf_data_dir)/plugins/$1"
  else
    echo "$(asdf_data_dir)/plugins"
  fi
}

display_error() {
  echo >&2 "$1"
}

get_version_in_dir() {
  local plugin_name=$1
  local search_path=$2
  local legacy_filenames=$3

  local asdf_version
  asdf_version=$(parse_asdf_version_file "$search_path/.tool-versions" "$plugin_name")

  if [ -n "$asdf_version" ]; then
    echo "$asdf_version|$search_path/.tool-versions"
    return 0
  fi

  for filename in $legacy_filenames; do
    local legacy_version
    legacy_version=$(parse_legacy_version_file "$search_path/$filename" "$plugin_name")

    if [ -n "$legacy_version" ]; then
      echo "$legacy_version|$search_path/$filename"
      return 0
    fi
  done
}

find_versions() {
  local plugin_name=$1
  local search_path=$2

  local version
  version=$(get_version_from_env "$plugin_name")
  if [ -n "$version" ]; then
    local upcase_name
    upcase_name=$(echo "$plugin_name" | tr '[:lower:]-' '[:upper:]_')
    local version_env_var="ASDF_${upcase_name}_VERSION"

    echo "$version|$version_env_var environment variable"
    return 0
  fi

  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")
  local legacy_config
  legacy_config=$(get_asdf_config_value "legacy_version_file")
  local legacy_list_filenames_script
  legacy_list_filenames_script="${plugin_path}/bin/list-legacy-filenames"
  local legacy_filenames=""

  if [ "$legacy_config" = "yes" ] && [ -f "$legacy_list_filenames_script" ]; then
    legacy_filenames=$(bash "$legacy_list_filenames_script")
  fi

  while [ "$search_path" != "/" ]; do
    version=$(get_version_in_dir "$plugin_name" "$search_path" "$legacy_filenames")
    if [ -n "$version" ]; then
      echo "$version"
      return 0
    fi
    search_path=$(dirname "$search_path")
  done

  get_version_in_dir "$plugin_name" "$HOME" "$legacy_filenames"

  if [ -f "$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME" ]; then
    versions=$(parse_asdf_version_file "$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME" "$plugin_name")
    if [ -n "$versions" ]; then
      echo "$versions|$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME"
      return 0
    fi
  fi
}

display_no_version_set() {
  local plugin_name=$1
  echo "No version set for ${plugin_name}; please run \`asdf <global | local> ${plugin_name} <version>\`"
}

get_version_from_env() {
  local plugin_name=$1
  local upcase_name
  upcase_name=$(echo "$plugin_name" | tr '[:lower:]-' '[:upper:]_')
  local version_env_var="ASDF_${upcase_name}_VERSION"
  local version=${!version_env_var}
  echo "$version"
}

find_install_path() {
  local plugin_name=$1
  local version=$2

  # shellcheck disable=SC2162
  IFS=':' read -a version_info <<<"$version"

  if [ "$version" = "system" ]; then
    echo ""
  elif [ "${version_info[0]}" = "ref" ]; then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
    get_install_path "$plugin_name" "$install_type" "$version"
  elif [ "${version_info[0]}" = "path" ]; then
    # This is for people who have the local source already compiled
    # Like those who work on the language, etc
    # We'll allow specifying path:/foo/bar/project in .tool-versions
    # And then use the binaries there
    local install_type="path"
    local version="path"
    echo "${version_info[1]}"
  else
    local install_type="version"
    local version="${version_info[0]}"
    get_install_path "$plugin_name" "$install_type" "$version"
  fi
}

get_custom_executable_path() {
  local plugin_path=$1
  local install_path=$2
  local executable_path=$3

  # custom plugin hook for executable path
  if [ -x "${plugin_path}/bin/exec-path" ]; then
    cmd=$(basename "$executable_path")
    local relative_path
    # shellcheck disable=SC2001
    relative_path=$(echo "$executable_path" | sed -e "s|${install_path}/||")
    relative_path="$("${plugin_path}/bin/exec-path" "$install_path" "$cmd" "$relative_path")"
    executable_path="$install_path/$relative_path"
  fi

  echo "$executable_path"
}

get_executable_path() {
  local plugin_name=$1
  local version=$2
  local executable_path=$3

  check_if_version_exists "$plugin_name" "$version"

  if [ "$version" = "system" ]; then
    path=$(echo "$PATH" | sed -e "s|$(asdf_data_dir)/shims||g; s|::|:|g")
    cmd=$(basename "$executable_path")
    cmd_path=$(PATH=$path command -v "$cmd" 2>&1)
    # shellcheck disable=SC2181
    if [ $? -ne 0 ]; then
      return 1
    fi
    echo "$cmd_path"
  else
    local install_path
    install_path=$(find_install_path "$plugin_name" "$version")
    echo "${install_path}"/"${executable_path}"
  fi
}

parse_asdf_version_file() {
  local file_path=$1
  local plugin_name=$2

  if [ -f "$file_path" ]; then
    local version
    version=$(strip_tool_version_comments "$file_path" | grep "^${plugin_name} " | sed -e "s/^${plugin_name} //")
    if [ -n "$version" ]; then
      echo "$version"
      return 0
    fi
  fi
}

parse_legacy_version_file() {
  local file_path=$1
  local plugin_name=$2

  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")
  local parse_legacy_script
  parse_legacy_script="${plugin_path}/bin/parse-legacy-file"

  if [ -f "$file_path" ]; then
    if [ -f "$parse_legacy_script" ]; then
      bash "$parse_legacy_script" "$file_path"
    else
      cat "$file_path"
    fi
  fi
}

get_preset_version_for() {
  local plugin_name=$1
  local search_path
  search_path=$(pwd)
  local version_and_path
  version_and_path=$(find_versions "$plugin_name" "$search_path")
  local version
  version=$(cut -d '|' -f 1 <<<"$version_and_path")

  echo "$version"
}

get_asdf_config_value_from_file() {
  local config_path=$1
  local key=$2

  if [ ! -f "$config_path" ]; then
    return 1
  fi

  local result
  result=$(grep -E "^\\s*$key\\s*=\\s*" "$config_path" | head | awk -F '=' '{print $2}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  if [ -n "$result" ]; then
    echo "$result"
    return 0
  fi

  return 2
}

get_asdf_config_value() {
  local key=$1
  local config_path=${ASDF_CONFIG_FILE:-"$HOME/.asdfrc"}
  local default_config_path=${ASDF_CONFIG_DEFAULT_FILE:-"$(asdf_dir)/defaults"}

  local local_config_path
  local_config_path="$(find_file_upwards ".asdfrc")"

  get_asdf_config_value_from_file "$local_config_path" "$key" ||
    get_asdf_config_value_from_file "$config_path" "$key" ||
    get_asdf_config_value_from_file "$default_config_path" "$key"
}

repository_needs_update() {
  local update_file_dir
  update_file_dir="$(asdf_data_dir)/tmp"
  local update_file_name
  update_file_name="repo-updated"
  # `find` outputs filename if it has not been modified in the last day
  local find_result
  find_result=$(find "$update_file_dir" -name "$update_file_name" -type f -mtime +1 -print)
  [ -n "$find_result" ]
}

initialize_or_update_repository() {
  local repository_url
  local repository_path

  repository_url=$(asdf_repository_url)
  repository_path=$(asdf_data_dir)/repository

  if [ ! -d "$repository_path" ]; then
    echo "initializing plugin repository..."
    git clone "$repository_url" "$repository_path"
  elif repository_needs_update; then
    echo "updating plugin repository..."
    (cd "$repository_path" && git fetch && git reset --hard origin/master)
  fi

  mkdir -p "$(asdf_data_dir)/tmp"
  touch "$(asdf_data_dir)/tmp/repo-updated"
}

get_plugin_source_url() {
  local plugin_name=$1
  local plugin_config

  plugin_config="$(asdf_data_dir)/repository/plugins/$plugin_name"

  if [ -f "$plugin_config" ]; then
    grep "repository" "$plugin_config" | awk -F'=' '{print $2}' | sed 's/ //'
  fi
}

find_tool_versions() {
  find_file_upwards ".tool-versions"
}

find_file_upwards() {
  local name="$1"
  local search_path
  search_path=$(pwd)
  while [ "$search_path" != "/" ]; do
    if [ -f "$search_path/$name" ]; then
      echo "${search_path}/$name"
      return 0
    fi
    search_path=$(dirname "$search_path")
  done
}

resolve_symlink() {
  local symlink
  symlink="$1"

  # This seems to be the only cross-platform way to resolve symlink paths to
  # the real file path.
  # shellcheck disable=SC2012
  resolved_path=$(ls -l "$symlink" | sed -e 's|.*-> \(.*\)|\1|')

  # Check if resolved path is relative or not by looking at the first character.
  # If it is a slash we can assume it's root and absolute. Otherwise we treat it
  # as relative
  case $resolved_path in
    /*)
      echo "$resolved_path"
      ;;
    *)
      echo "$PWD/$resolved_path"
      ;;
  esac
}

list_plugin_bin_paths() {
  local plugin_name=$1
  local version=$2
  local install_type=$3
  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")
  local install_path
  install_path=$(get_install_path "$plugin_name" "$install_type" "$version")

  if [ -f "${plugin_path}/bin/list-bin-paths" ]; then
    local space_separated_list_of_bin_paths

    # shellcheck disable=SC2030
    space_separated_list_of_bin_paths=$(
      export ASDF_INSTALL_TYPE=$install_type
      export ASDF_INSTALL_VERSION=$version
      export ASDF_INSTALL_PATH=$install_path
      bash "${plugin_path}/bin/list-bin-paths"
    )
  else
    local space_separated_list_of_bin_paths="bin"
  fi
  echo "$space_separated_list_of_bin_paths"
}

list_plugin_exec_paths() {
  local plugin_name=$1
  local full_version=$2
  check_if_plugin_exists "$plugin_name"

  IFS=':' read -r -a version_info <<<"$full_version"
  if [ "${version_info[0]}" = "ref" ]; then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
  else
    local install_type="version"
    local version="${version_info[0]}"
  fi

  local plugin_shims_path
  plugin_shims_path=$(get_plugin_path "$plugin_name")/shims
  if [ -d "$plugin_shims_path" ]; then
    echo "$plugin_shims_path"
  fi

  space_separated_list_of_bin_paths="$(list_plugin_bin_paths "$plugin_name" "$version" "$install_type")"
  IFS=' ' read -r -a all_bin_paths <<<"$space_separated_list_of_bin_paths"

  local install_path
  install_path=$(get_install_path "$plugin_name" "$install_type" "$version")

  for bin_path in "${all_bin_paths[@]}"; do
    echo "$install_path/$bin_path"
  done
}

with_plugin_env() {
  local plugin_name=$1
  local full_version=$2
  local callback=$3

  IFS=':' read -r -a version_info <<<"$full_version"
  if [ "${version_info[0]}" = "ref" ]; then
    local install_type="${version_info[0]}"
    local version="${version_info[1]}"
  else
    local install_type="version"
    local version="${version_info[0]}"
  fi

  if [ "$version" = "system" ]; then
    # execute as is for system
    "$callback"
    return $?
  fi

  local plugin_path
  plugin_path=$(get_plugin_path "$plugin_name")

  # add the plugin listed exec paths to PATH
  local path exec_paths
  exec_paths="$(list_plugin_exec_paths "$plugin_name" "$full_version")"

  # exec_paths contains a trailing newline which is converted to a colon, so no
  # colon is needed between the subshell and the PATH variable in this string
  path="$(echo "$exec_paths" | tr '\n' ':')$PATH"

  # If no custom exec-env transform, just execute callback
  if [ ! -f "${plugin_path}/bin/exec-env" ]; then
    PATH=$path "$callback"
    return $?
  fi

  # Load the plugin custom environment
  local install_path
  install_path=$(find_install_path "$plugin_name" "$full_version")

  # shellcheck source=/dev/null
  ASDF_INSTALL_TYPE=$install_type \
    ASDF_INSTALL_VERSION=$version \
    ASDF_INSTALL_PATH=$install_path \
    source "${plugin_path}/bin/exec-env"

  PATH=$path "$callback"
}

plugin_executables() {
  local plugin_name=$1
  local full_version=$2
  for bin_path in $(list_plugin_exec_paths "$plugin_name" "$full_version"); do
    for executable_file in "$bin_path"/*; do
      if is_executable "$executable_file"; then
        echo "$executable_file"
      fi
    done
  done
}

is_executable() {
  local executable_path=$1
  if [[ (-f "$executable_path") && (-x "$executable_path") ]]; then
    return 0
  fi
  return 1
}

plugin_shims() {
  local plugin_name=$1
  local full_version=$2
  grep -lx "# asdf-plugin: $plugin_name $full_version" "$(asdf_data_dir)/shims"/* 2>/dev/null
}

shim_plugin_versions() {
  local executable_name
  executable_name=$(basename "$1")
  local shim_path
  shim_path="$(asdf_data_dir)/shims/${executable_name}"
  if [ -x "$shim_path" ]; then
    grep "# asdf-plugin: " "$shim_path" 2>/dev/null | sed -e "s/# asdf-plugin: //" | uniq
  else
    echo "asdf: unknown shim $executable_name"
    return 1
  fi
}

strip_tool_version_comments() {
  local tool_version_path="$1"

  while IFS= read -r tool_line || [ -n "$tool_line" ]; do
    # Remove whitespace before pound sign, the pound sign, and everything after it
    new_line="$(echo "$tool_line" | cut -f1 -d"#" | sed -e 's/[[:space:]]*$//')"

    # Only print the line if it is not empty
    if [[ -n "$new_line" ]]; then
      echo "$new_line"
    fi
  done <"$tool_version_path"
}

asdf_run_hook() {
  local hook_name=$1
  local hook_cmd
  hook_cmd="$(get_asdf_config_value "$hook_name")"
  if [ -n "$hook_cmd" ]; then
    asdf_hook_fun() {
      unset asdf_hook_fun
      ev'al' "$hook_cmd" # ignore banned command just here
    }
    asdf_hook_fun "${@:2}"
  fi
}

with_shim_executable() {
  get_shim_versions() {
    shim_plugin_versions "${shim_name}"
    shim_plugin_versions "${shim_name}" | cut -d' ' -f 1 | awk '{print$1" system"}'
  }

  preset_versions() {
    shim_plugin_versions "${shim_name}" | cut -d' ' -f 1 | uniq | xargs -IPLUGIN bash -c "source $(asdf_dir)/lib/utils.sh; echo PLUGIN \$(get_preset_version_for PLUGIN)"
  }

  select_from_preset_version() {
    grep -f <(get_shim_versions) <(preset_versions) | head -n 1 | xargs echo
  }

  select_version() {
    # First, we get the all the plugins where the
    # current shim is available.
    # Then, we iterate on all versions set for each plugin
    # Note that multiple plugin versions can be set for a single plugin.
    # These are separated by a space. e.g. python 3.7.2 2.7.15
    # For each plugin/version pair, we check if it is present in the shim
    local search_path
    search_path=$(pwd)
    local shim_versions
    IFS=$'\n' read -rd '' -a shim_versions <<<"$(get_shim_versions)"

    local plugins
    plugins=()

    for plugin_and_version in "${shim_versions[@]}"; do
      local plugin_name
      local plugin_shim_version
      IFS=' ' read -r plugin_name _plugin_shim_version <<<"$plugin_and_version"
      if ! [[ " ${plugins[*]} " == *" $plugin_name "* ]]; then
        plugins+=("$plugin_name")
      fi
    done

    for plugin_name in "${plugins[@]}"; do
      local version_and_path
      local version_string
      local usable_plugin_versions
      local _path
      version_and_path=$(find_versions "$plugin_name" "$search_path")
      IFS='|' read -r version_string _path <<<"$version_and_path"
      IFS=' ' read -r -a usable_plugin_versions <<<"$version_string"
      for plugin_version in "${usable_plugin_versions[@]}"; do
        for plugin_and_version in "${shim_versions[@]}"; do
          local plugin_shim_name
          local plugin_shim_version
          IFS=' ' read -r plugin_shim_name plugin_shim_version <<<"$plugin_and_version"
          if [[ "$plugin_name" == "$plugin_shim_name" ]] &&
            [[ "$plugin_version" == "$plugin_shim_version" ]]; then
            echo "$plugin_name $plugin_version"
            return
          fi
        done
      done
    done
  }

  local shim_name
  shim_name=$(basename "$1")
  local shim_exec="${2}"

  if [ ! -f "$(asdf_data_dir)/shims/${shim_name}" ]; then
    echo "unknown command: ${shim_name}. Perhaps you have to reshim?" >&2
    return 1
  fi

  local selected_version
  selected_version="$(select_version)"

  if [ -z "$selected_version" ]; then
    selected_version=$(select_from_preset_version)
  fi

  if [ -n "$selected_version" ]; then
    local plugin_name
    local full_version
    local plugin_path

    IFS=' ' read -r plugin_name full_version <<<"$selected_version"
    plugin_path=$(get_plugin_path "$plugin_name")

    run_within_env() {
      local path=$PATH
      if [ "system" == "$full_version" ]; then
        path=$(echo "$PATH" | sed -e "s|$(asdf_data_dir)/shims||g; s|::|:|g")
      fi

      executable_path=$(PATH=$path command -v "$shim_name")

      if [ -x "${plugin_path}/bin/exec-path" ]; then
        install_path=$(find_install_path "$plugin_name" "$full_version")
        executable_path=$(get_custom_executable_path "${plugin_path}" "${install_path}" "${executable_path:-${shim_name}}")
      fi

      "$shim_exec" "$plugin_name" "$full_version" "$executable_path"
    }

    with_plugin_env "$plugin_name" "$full_version" run_within_env
    return $?
  fi

  (
    local preset_version
    preset_version=$(get_preset_version_for "$shim_name")

    if [ -n "$preset_version" ]; then
      echo "asdf: No version ${preset_version} installed for command ${shim_name}"
      echo "Please install the missing version by running"
      echo ""
      echo "asdf install ${shim_name} ${preset_version}"
      echo ""
      echo "or add one of the following in your .tool-versions file:"
    else
      echo "asdf: No version set for command ${shim_name}"
      echo "you might want to add one of the following in your .tool-versions file:"
    fi
    echo ""
    shim_plugin_versions "${shim_name}"
  ) >&2

  return 126
}

