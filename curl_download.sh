function download_url()
{
    FILE_URL=$1
    while true; do
        curl --connect-timeout 10 -C - -O $FILE_URL > /dev/null 2>&1
        if [ $? == 0 ]; then
            break
        fi
        # if the file finish the download the curl command will print
        # curl: (33) HTTP server doesn't seem to support byte ranges. Cannot resume.
        curl --connect-timeout 10 -C - -O $FILE_URL 2>&1 | grep "Cannot resume." > /dev/null
        if [ $? == 0 ]; then
            break
        fi
    done
}

