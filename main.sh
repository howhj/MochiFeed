#!/bin/bash

# TODO migrate data storage to SQLite
rss_file="subscriptions.txt"

get_channel_id () {
    if [[ "$1" != @* ]]; then
        echo "Invalid channel tag: ${1}. Channel tag should start with @."
        return 1
    fi

    # Get response from Youtube
    local url="https://www.youtube.com/${1}/videos"
    local response=$(curl -s -i "$url")

    # Check response status
    local status=$(grep "HTTP/2" <<< "$response")
    local status=${status#*'HTTP/2 '}
    local status=${status%' '*}
    echo "$status" > "curl.txt"
    if [ ! "$status" = 200 ]; then
        echo "Could not find channel for ${1}."
        return 2
    fi

    # Find and strip for channel ID
    id=$(grep -Po '"channelId":".+?"' <<< "$response")
    id=${id#*'"channelId":"'}
    id=${id%'"'}
}

# TODO update channels file
subscribe () {
    for tag in "$@"; do
        get_channel_id "$tag"
        if [ $? != 0 ]; then
            continue
        fi

        # Check if channel has already been added, and exit if so
        local check=$(grep "$id" "$rss_file")
        if [ "$check" != "" ]; then
            echo "Already subscribed to ${tag}."
            continue
        fi

        # Append RSS feed link to RSS feed file
        echo "https://www.youtube.com/feeds/videos.xml?channel_id=${id}" >> "$rss_file"
        echo "Successfully subscribed to ${tag}!"
    done
}

# TODO switch to yay menu
unsubscribe () {
    for tag in "$@"; do
        get_channel_id "$tag"
        if [ $? != 0 ]; then
            continue
        fi

        # Search for RSS feed in RSS file
        local i=$(grep -Fn "$id" "$rss_file")
        if [ "$i" = "" ]; then
            echo "Not subscribed to ${tag}."
            continue
        fi

        # Remove RSS feed from RSS file
        local i="${i%":https://www.youtube.com/feeds/videos.xml?channel_id="*}"
        local updated_list=$(sed "${i}d" "$rss_file")
        echo "$updated_list" > "$rss_file"
        echo "Successfully unsubscribed from ${tag}!"
    done
}

retry_downloads () {
    echo "To be implemented"
}

list_channels () {
    echo "To be implemented"
}

print_usage () {
    echo "To be implemented"
}

error () {
    echo "To be implemented"
}

case $1 in
    -s) ./sync.sh ;;
    -a) subscribe ${@:2} ;;
    -d) unsubscribe ${@:2} ;;
    -r) retry_downloads ;;
    -c) list_channels ;;
    -h) print_usage ;;
    *) error ;;
esac

