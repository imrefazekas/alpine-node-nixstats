SERVER=5bd9828f075eee5acc3c58c9

createConfFile()
{
        parseTags
        VERSION="$(rsyslogd -v)"
        VERSION_NUMBER="${VERSION:9:1}"
        echo "rsyslog version is $VERSION_NUMBER"
        if [ ! -d "/var/spool/rsyslog" ]; then
                echo "Creating rsyslog work directory"
                mkdir -p /var/spool/rsyslog
        fi
        if [ ! -d "/etc/rsyslog.d/keys" ]; then
                echo "Creating rsyslog keys directory"
                mkdir -p /etc/rsyslog.d/keys
        fi
        if [ ! -f "/etc/rsyslog.d/keys/nixstats.ca" ]; then
                wget --quiet -O /etc/rsyslog.d/keys/nixstats.ca https://www.nixstats.com/nixstats.ca
                echo "Downloading TLS CA file"
        fi
        if [ $VERSION_NUMBER -le 7 ]; then
                LOGFILECONTENT="\$WorkDirectory /var/spool/rsyslog/
\$ActionSendStreamDriver gtls
\$ActionSendStreamDriverMode 1
\$ActionSendStreamDriverAuthMode x509/name
\$ActionSendStreamDriverPermittedPeer log.nixstats.com
\$DefaultNetstreamDriverCAFile /etc/rsyslog.d/keys/nixstats.ca
\$ActionQueueFileName fwdRule1
\$ActionQueueMaxDiskSpace 1g
\$ActionQueueSaveOnShutdown on
\$ActionQueueType LinkedList
\$ActionResumeRetryCount -1

\$template NixstatsLogFormat,\"<%pri%>%protocol-version% %timestamp:::date-rfc3339% %HOSTNAME% %app-name% %procid% %msgid% [$SERVER@$TOKEN $TAG] %msg%\n\"
*.* @@log.nixstats.com:10514;NixstatsLogFormat
                "
        else
                LOGFILECONTENT="\$WorkDirectory /var/spool/rsyslog/
\$ActionQueueFileName fwdRule1
\$ActionQueueMaxDiskSpace 1g
\$ActionQueueSaveOnShutdown on
\$ActionQueueType LinkedList
\$ActionResumeRetryCount -1
\$DefaultNetstreamDriverCAFile /etc/rsyslog.d/keys/nixstats.ca
template(name=\"NixstatsLogFormat\" type=\"string\" string=\"<%pri%>%protocol-version% %timestamp:::date-rfc3339% %HOSTNAME% %app-name% %procid% %msgid% [$SERVER@$TOKEN $TAG] %msg%\n\")
action(type=\"omfwd\" protocol=\"tcp\" target=\"log.nixstats.com\" port=\"10514\" template=\"NixstatsLogFormat\" StreamDriver=\"gtls\" StreamDriverMode=\"1\" StreamDriverAuthMode=\"x509/name\" StreamDriverPermittedPeers=\"log.nixstats.com\")
                "
        fi
cat << EOIPFW >> /etc/rsyslog.d/31-nixstats.conf
$LOGFILECONTENT
EOIPFW
        echo "Config file saved"
}

parseTags()
{
        TAG="tag=\\\"rsyslog\\\" "
        IFS=, read -a array <<< "$TAGS"
        for i in "${array[@]}"
        do
                TAG="$TAG tag=\\\"$i\\\" "
        done
}

installDeps()
{
echo "Removed deps check..."
}

usage()
{
cat << EOF
arguments: [-u log user token] [-s nixstats server id (optional)] [-t tag1,tag2,tag3... (optional, comma separated)]
EOF
}

if [ "$(id -u)" != "0" ];
then
   echo "This script needs to be run as root."
   exit 1
fi

if [ $# -eq 0 ]; then
    usage
    exit
else
    while [ "$1" != "" ]; do
        case $1 in
          -u | --token ) shift
             TOKEN=$1
             echo "User token: $TOKEN"
             if [ -f "/etc/rsyslog.d/31-nixstats.conf" ]; then
                echo "Logging config already found (/etc/rsyslog.d/31-nixstats.conf)"
                echo "Stopping installer"
                exit 1
             fi
             ;;
          -t | --tags ) shift
             TAGS=$1
             echo "Tags: $TAGS"
             ;;
          -s | --server ) shift
             SERVER=$1
             echo "Server: $SERVER"
             ;;
          -h | --help)
              usage
              exit
              ;;
        esac
        shift
    done
fi

installDeps
createConfFile
