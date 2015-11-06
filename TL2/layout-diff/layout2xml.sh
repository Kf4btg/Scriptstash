#!/bin/sh

#=== GLOBALS ========================================
#====================================================
__ScriptVersion="1.2"
__script_name="$(basename "$0")"

# hack in location of python-sorter-script
PYSORTER="$(dirname "$0")"/layout-xml-sorter.py

#FIXME: clean this up
_gamesdir="${JENV_GAMES:-/home/DATA/games}"
TL2DIR="${TL2DIR:-$_gamesdir/WineSteamberry/Torchlight II}"
MEDIA1="${MEDIA1:-$TL2DIR/MEDIA}"
MEDIA2="${MEDIA2:-$TL2DIR/mods/UNEARTHED_ARCANA/MEDIA}"

OUTPUT_DIR="${OUTPUT_DIR:-/home/DATA/Games/Runic Games/layout-merge}"


RELPATH1=
RELPATH2=


#exit 0



#===  FUNCTION  ================================================================
#         NAME:  layout_to_xml
#  DESCRIPTION: command which takes an unmodified .layout file (in UTF-16LE
#               encoding) and mutates it line-by-line into a valid XML document.
#
# NOTES:- this ONLY works for .layout files!
#       - "UNSIGNED INT" had to be changed to "UNSIGNED_INT" so as not to
#       confuse the xml parser
#       - for a similar reason, have to make sure to url-encode '&' as '&amp;'
#===============================================================================
layout_to_xml() {
    # usage: layout_to_xml input_file output_file
    
    # guess the encoding:
    ## could use a number of tools; 
    # "file" is probably most standardized
    # "encguess" depends only on perl
    # "chardetect" depends on python-chardet
    
    local layout="$1"
    local outfile="$2"
    
    local enc="$(file --brief --mime-encoding "$layout")"
    local cmd=
    
    case $enc in
        utf-16*) #just use utf-16 & let the BOM do its job
            cmd="cat $layout | iconv -f UTF16"
#             echo $cmd >&2
            ;;
        us-ascii) # does this take special processing?
            cmd="cat $layout | iconv -f ASCII -t UTF8"
            ;;
        #add more if they come up;
        *) cmd="cat $layout" ;;
    esac
                echo $cmd >&2

#     cat "$1" | \ #
#     iconv -f UTF16 | \ #
    eval $cmd | sed -r '

    s#&#\&amp;#g
    s#(UNSIGNED) (INT)#\1_\2#g

    s#^(\s*)<([^>]+)>([^:]+):([^\r]*)[\r]?$#\1<\2 label="\3">\4</\2>#


    s#^(\s*)\[([^\]+)\]#\1<\2>#
    ' > "$outfile"

}
#    sed -r \
#   -e 's#^(\s*)<([^>]+)>([^:]+):(.*)\r$#\1<\2 label="\3">\4</\2>#g' \
#   -e 's#UNSIGNED INT#UNSIGNED_INT#g' \
#   -e 's#^(\s*)\[([^\]+)\]#\1<\2>#g' \
#   > "$2"

#===  FUNCTION  ================================================================
#        USAGE: xml_to_layout input.xml output.layout
#  DESCRIPTION: Takes an xml-converted layout file and transforms it back to
#               .layout syntax
#===============================================================================
xml_to_layout() {
    # <(1:TYPE_NAME) label=(2:LABEL)(>|/>)(5:VALUE)?(</TYPE_NAME>)?
    #  |
    #  | becomes
    #  V
    # <TYPE NAME>LABEL:VALUE

    # -second cmd returns the space to unsigned_int
    # -third section chops off all decimals at precision 3 to cut down on 
    # on diffs that were just from VERY tiny rounding differences
    # -last part just turns <SECTION> into [SECTION]

    # also, make an initial pass through unexpand to restore the tabs that
    # python replaced with spaces (for ease of diff-ing)

    cat "$1" | unexpand -t2 --first-only | \
        sed -r '

        /label=/ {
            s#&amp;#\&#g

            s#<([A-Z0-9_]+) label="([a-zA-Z_ -]+)"(>|/>)(([^<]+)?</\1>)?$#<\1>\2:\5#g

            s#(UNSIGNED)_(INT)#\1 \2#g
        
            s#(((FORWARD|RIGHT|UP)[XYZ]|YAW):-?)([0-9]+\.[0-9]{3})[0-9]+#\1\4#

        }

        s#^(\s*)<([^>]+)>\r?$#\1[\2]#g
    ' > "$2"
}

#===  FUNCTION  ================================================================
#        USAGE: layout_to_dot input.layout
#  DESCRIPTION: Outputs a graphviz-format visualization of the layout
#===============================================================================
layout_to_dot() {
    local input="$1"
    local tag="LOGICGROUP" # for testing

}

#===  FUNCTION  ================================================================
#         NAME: main
#  DESCRIPTION: Script entry point. Call with: main file1 file2
#===============================================================================
main() {

    local tmpdir="$(mktemp -d -t layout-diff.XXXXXX)"
    trap "rm -rf '$tmpdir'" 0               # EXIT
    trap "rm -rf '$tmpdir'; exit 1" 2       # INT
    trap "rm -rf '$tmpdir'; exit 1" 1 15    # HUP TERM

    # assign files to variables
    layout1="$1"
    layout2="$2"

    # extract filenames
    bname1=$(basename "${layout1}")
    bname2=$(basename "${layout2}")

    # define output xml files
    xmlout1="${tmpdir}/${bname1}.o.xml"
    xmlout2="${tmpdir}/${bname2}.m.xml"
    # sorted-xml output files
    s_xmlout1="${tmpdir}/${bname1}.o_sorted.xml"
    s_xmlout2="${tmpdir}/${bname2}.m_sorted.xml"
    # and the re-converted, sorted layout files
    s_layout1="${tmpdir}/${bname1}.o.layout"
    s_layout2="${tmpdir}/${bname2}.m.layout"

    # transform layouts to xml
    layout_to_xml "$layout1" "$xmlout1"
    layout_to_xml "$layout2" "$xmlout2"

    # read in just-created xml files, sort on BASEOBJECT.PROPERTIES.ID,
    # and write back to files
    python "$PYSORTER" "$xmlout1" > "${s_xmlout1}"
    python "$PYSORTER" "$xmlout2" > "${s_xmlout2}"

    # transform sorted xml files back to regular layout syntax
    xml_to_layout "${s_xmlout1}" "${s_layout1}"
    xml_to_layout "${s_xmlout2}" "${s_layout2}"

    # TODO: bring up diff program and save merged file to disk?


    _exit=0
    if [[ "$SORT_AND_SAVE" ]]; then

        subpath1="$(dirname "$RELPATH1")"
        subpath2="$(dirname "$RELPATH2")"

        # create the parent dirs, then copy the sorted files to the 
        # output directories

        cpopts="-n"
        [[ "$FORCE" ]] && cpopts="-f"

        mkdir -p "${OUTPUT_DIR}/MEDIA1/$subpath1" "${OUTPUT_DIR}/MEDIA2/$subpath2" && \
        cp $cpopts "${s_layout1}" "${OUTPUT_DIR}/MEDIA1/$RELPATH1" && \
        cp $cpopts "${s_layout2}" "${OUTPUT_DIR}/MEDIA2/$RELPATH2"

        exit $?
    elif [[ "$BRIEF" ]] ; then
        diff -q -s --ignore-file-name-case -w -B "${s_layout1}" "${s_layout2}"
        _exit=$?
    fi


    # wait for key-press before deleting temp files
    read -p "press enter to continue"

    exit $_exit

}



#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
    BOLD=$'\e[1m'
    UNDL=$'\e[4m'
    OFF=$'\e[0m'
    
    echo "${BOLD}Usage :  $__script_name [options] FILE1 [FILE2]
    Prepare two Torchlight II .layout files for diff comparison.

    Unless it begins with '/', a given filename is taken to be
    a path relative to the defined parent MEDIA folders
    (see ${BOLD}ENVIRONMENT VARIABLES$OFF below for what these default to).
    If ${UNDL}FILE2$OFF is omitted, $__script_name will automatically select
    the file with the same relative path as ${UNDL}FILE1$OFF from the secondary 
    MEDIA folder and use it as the comparison file. For example,

        \$ $__script_name LAYOUTS/ACT1/ENVIRONMENT.LAYOUT

    is equivalent to

        \$ $__script_name '$MEDIA1/LAYOUTS/ACT1/ENVIRONMENT.LAYOUT' \\
              '$MEDIA2/LAYOUTS/ACT1/ENVIRONMENT.LAYOUT'


${BOLD}OPTIONS$OFF
    -h      Display this message
    -v      Display script version

    -d      Dry run: report the operations that would be taken, but do not
            actually read or write any files.
    
    -q      Brief: Report only if the files differ.
    
    -s      Sort and Save: save the sorted layout files to the directory
            specified by -o rather than deleting them after script execution.
            
    -o      Output Directory: use this directory rather than a temporary
            directory to output files.
            
    -f      Force: when used with -s, overwrite any destination files that
            already exist in the output directory. Without this option, these
            files will be skipped and the pre-existing versions left in place.

    -L      If ${UNDL}FILE1$OFF is an xml file output by the -X option (see below),
            convert ${UNDL}FILE1$OFF back to .LAYOUT format and print it to stdout.
            
            This option overrides all options other than -X, in which case
            it is ignored. Any filenames beyond the first are ignored.
            
    -X      If ${UNDL}FILE1$OFF is a .layout file, print the XML for ${UNDL}FILE1$OFF to stdout.
            If combined with the -s option, the XML will be sorted prior
            to printing.

            This option overrides all options other than -s (as noted above).
            Any filenames beyond the first are ignored.


${BOLD}ENVIRONMENT VARIABLES$OFF

    TL2DIR
        The base Torchlight II directory, i.e. the one containing the
        Torchlight II executable and the unpacked MEDIA folder.

        Current default: $TL2DIR

    MEDIA1
        The main MEDIA directory, as unpacked by GUTS. By default, this is
        defined in terms of TL2DIR.

        Current default: $MEDIA1

    MEDIA2
        The secondary MEDIA directory, containing the modified files you'd
        like to compare to the vanilla files in MEDIA1. By default, this is
        defined in terms of TL2DIR.

        Current default: $MEDIA2
" | sed 's@'$__script_name'\|[[:space:]]-[A-z]\|[[:space:]]MEDIA[12]\?\|TL2DIR@'$BOLD'&'$OFF'@g'

}

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

while getopts ":hvdqfso:LX" opt
do
  case $opt in

    h)  usage; exit 0   ;;

    d)  DRYRUN=1 ;;

    q)  BRIEF=1 ;;

    o)  OUTPUT_DIR="${OPTARG}"
        [ -d "$OUTPUT_DIR" ] || {
            echo "$__script_name: specified output directory '$OUTPUT_DIR' does not exist" >&2
            exit 69
        };;

    s)  SORT_AND_SAVE=1 ;;

    f)  FORCE=1 ;;

    L)  PRINT_LAYOUT=1 ;;

    X)  PRINT_XML=1 ;;

    v)  echo "$__script_name -- Version $__ScriptVersion"; exit 0   ;;

    * )  echo -e "\n  Option does not exist : $OPTARG\n"
          usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))



## make sure we have at least 1 argument (only first 2 are considered)
if [ $# -lt 1 ] ; then
    usage >&2
    exit 1
fi

## always do this
RELPATH1="$1"
## if the first filename starts with '/'...
if [[ "$1" =~ ^/ ]] ; then
    ## abspath given, so RELPATH and the file are the same
    file1="$1"
else
    file1="$MEDIA1"/"$RELPATH1"
fi

# check for existence of file1 before continuing
[[ -e "$file1" ]] || { echo "$__script_name: file $file1 could not be found." >&2;
                        exit 66 ; }

## now check for PRINT_XML; we can interrupt normal operation
## here if it's present
if [[ "$PRINT_XML" ]] ; then
    if [[ "$SORT_AND_SAVE" ]] ; then
        xmlpipe=/tmp/lo2xmlpipe
        trap "rm -f $xmlpipe; exit" EXIT INT TERM
        
        mkfifo $xmlpipe
        
        layout_to_xml "$file1" $xmlpipe &
        python "$PYSORTER" $xmlpipe
    else
        layout_to_xml "$file1" /dev/stdout
    fi
    
    exit 0
elif [[ "$PRINT_LAYOUT" ]] ; then
    xml_to_layout $file1 /dev/stdout
    exit 0
fi

shift
## if there are remaining filenames
if [ $# -gt 0 ] ; then

    RELPATH2="$1"
    
    ## check for abspath:
    ## if the argument starts with '/'...
    if [[ "$RELPATH" =~ ^/ ]] ; then
        ## abspath given, so RELPATH and the file are the same
        file2="$RELPATH"
    else
        file2="$MEDIA2"/"$RELPATH2"
    fi
else
    ## infer relpath2 from single arg
    
    RELPATH2="$RELPATH1"
    file2="$MEDIA2"/"$RELPATH2"
fi


## It seems not too difficult to mistakenly end up with file1 & file2 the same:
if [[ "$file1" == "$file2" ]]; then
    echo "$__script_name: the given filenames both refer to the same file: $file1" >&2
    exit 66
elif [[ ! -e "$file2" ]] ; then
    ## and now check that file2 exists
    echo "$__script_name: file $file2 could not be found." >&2
    exit 66
fi


# file1="$MEDIA1"/"$RELPATH1"
# file2="$MEDIA2"/"$RELPATH2"

# [[ -e "$file1" ]] || { echo "$__script_name: file $file1 could not be found." >&2;
#                         exit 66 ; }
# [[ -e "$file2" ]] || { echo "$__script_name: file $file2 could not be found." >&2;
#                         exit 66 ; }

## check for existing output files and quit if they already exist
## unless FORCE is enabled
if [[ ! "$FORCE" ]] ; then
    [[ -e "${OUTPUT_DIR}/MEDIA1/$RELPATH1" ]] && exit 0
    [[ -e "${OUTPUT_DIR}/MEDIA2/$RELPATH2" ]] && exit 0
fi

#echo "$RELPATH1" >&2


[[ "$DRYRUN" ]] && {
    echo "
Base Layout file: $file1
 Modified Layout: $file2
 
Output Directory: $OUTPUT_DIR
"

exit 0
    
}



## execute main program
main "$file1" "$file2"

## Here's some notes on a fun, fancy, fast way to process lots of files
## with this utility in parallel and possibly catch your computer
## on fire. (i'm very proud.)

# SORTER=/path/to/this_script.sh
# cd to the $MEDIA2 folder and run:

# find LEVELSETS LAYOUTS -iname "*.layout" -print0 | parallel -0 -j150% "[ -e ../../../MEDIA/'{}' ] && '$SORTER' -s '{}'"



