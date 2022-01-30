#!/bin/bash

# Exit on error
set -e

# Parse arguments
args=$(getopt -l "filename:" -l "webhook:" -l "help" -l "verbose" -o "f:w:hv" -- "$@")
eval set -- "$args"

while [ $# -ge 1 ]; do
        case "$1" in
                --)
                    # No more options left.
                    shift
                    break
                   ;;
                -f|--filename)
                        filename="$2"
                        shift
                        ;;
                -w|--webhook)
                        webhook="$2"
                        shift
                        ;;
                -v|--verbose)
                        verbose="true"
                        ;;
                -h|--help)
                        printf "discbin.sh v1.0.0\n"
                        printf "Options:\n"
                        printf "  -h, --help                  Prints this message.\n"
                        printf "  -f, --filename <filename>   Use a custom filename for the uploaded file.\n"
                        printf "  -w, --webhook <URL>         Set the webhook URL.\n"
                        printf "                              Note: The webhook URL can also be set by\n"
                        printf "                              using the DISCBIN_WEBHOOK env variable\n"
                        printf "                              or hardcoding it into the shellscript.\n"
                        printf "  -v, --verbose               Verbose jq json output.\n"
                        printf "Examples:\n"
                        printf "  \033[1;30m# Upload a file\033[0m\n"
                        printf "  discbin.sh \033[1;33mdog.jpg\033[0m\n"
                        printf "  \033[1;30m# Upload a file with a custom filename\033[0m\n"
                        printf "  discbin.sh \033[1;33mdogs.zip\033[0m -f \033[1;33mcats.zip\033[0m\n"
                        printf "  \033[1;30m# Upload multiple files\033[0m\n"
                        printf "  discbin.sh \033[1;33mlogo.png logo.svg\033[0m\n"
                        printf "  discbin.sh \033[1;33m*.mp3\033[0m\n"
                        printf "  \033[1;30m# Upload piped content as a file\033[0m\n"
                        printf "  \033[1;33mfortune |\033[0m discbin.sh\n"
                        printf "  \033[1;33mls |\033[0m discbin.sh -f \033[1;33mfiles.txt\033[0m\n"
                        exit 0
                        ;;
        esac

        shift
done

# If webhook link specified with an argument.
if [ "$webhook" ]; then
    DISCBIN_WEBHOOK="${webhook}"
fi

# Uncomment the following line to hardcode a webhook.
# [ ! "$DISCBIN_WEBHOOK" ] && DISCBIN_WEBHOOK='https://discord.com/api/webhooks...'

# Verify the DISCBIN_WEBHOOK variable is set.
if [ ! "$DISCBIN_WEBHOOK" ]; then
    echo "DISCBIN_WEBHOOK variable not set. Set it in your ENV, hardcode it in the shellscript, or use the --webhook argument (see -h)."
    exit 1
fi

# Check if the DISCBIN_WEBHOOK variable looks fine.
if echo "${DISCBIN_WEBHOOK}" | grep -vq "https://discord.com/api/webhooks/.\+/.\+"; then
    echo "DISCBIN_WEBHOOK does not match the 'https://discord.com/api/webhooks/.+/.+' pattern, please double-check it."
    echo "Note: if the webhook URL has changed in the future for whatever reason, feel free to modify/remove this check from the script."
    exit 1
fi

# Don't allow custom filenames when multiple files are being uploaded.
if [ "$filename" ] && [ "$#" -gt "1" ]; then
    echo "Custom filenames cannot be used with multi-file upload."
    exit 1
fi

# Verify all the selected files actually exist.
for file in "$@"; do
    if [ ! -f "${file}" ]; then
        echo "File ${file} not found!"
        exit 1
    fi
done

# Parse the cdn url out of the file with jq.
parse_output() {
    if which jq >/dev/null; then
        printf '\033[1;33m'"$1"':\033[0m '
        if [ "$verbose" ]; then
            printf '\n'
            jq 'if .attachments then .attachments[] else . end'
        else
            jq 'if .attachments then .attachments[].url else . end'
        fi
    else
        printf '\033[0;31m[!] jq not found, install it for better output\033[0m\n'
        cat
        printf '\n'
    fi
}

if [ "$#" -eq "0" ]; then
    # If: file is coming from pipe/stdin, optionally with a custom filename.
    # Use default filename if not specified.
    [ ! "$filename" ] && filename="upload.txt"
    curl "${DISCBIN_WEBHOOK}" --silent --form "file=@- ;filename=${filename}" | parse_output "${filename}"
elif [ "$filename" ]; then
    # If: file uses custom filename.
    curl "${DISCBIN_WEBHOOK}" --silent --form "file=@$@ ;filename=${filename}" | parse_output "$@"
else
    # If: we are just uploading file(s).
    # We loop over every file and send them separately as it is generally preferred.
    # However, multiple files can be sent with the same request like this:
    # --form "file1=@file1.txt;filename=filename1.txt" --form "file2=@file2.txt;filename=filename2.txt"
    for file in "$@"; do
        curl "${DISCBIN_WEBHOOK}" --silent --form "file=@${file}" | parse_output "${file}"
    done
fi
