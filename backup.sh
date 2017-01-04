#!/bin/bash

### User Config ###
# Backup Config
DIRS=("/etc/docker/ghost" "/etc/docker/lychee" "/etc/docker/wordpress" "/etc/nginx/nginx.conf" "/etc/nginx/sites-available")

MYSQLCONTAINER="some-mysql"
MYSQLDBS=("wordpress" "lychee")

TMPDIR="/tmp/backup/"

# Glacier Config
SANDBOX="false"
CREDENTAILS="aws.properties"
ENDPOINT="https://glacier.us-east-1.amazonaws.com"
VAULT="myvault"
PARTSIZE=8388608

### Start of Script ###

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

BACKUPDIR=`echo $HOSTNAME"-"$TIMESTAMP`
echo "Backing Up to: "$TMPDIR$BACKUPDIR

mkdir -p $TMPDIR$BACKUPDIR;  # Make Temp Dir
for dir in ${DIRS[*]}; do
    # Make a copy of each of the Directories or files spcified above
    cp --recursive "$dir" "$TMPDIR$BACKUPDIR";
done

mkdir $TMPDIR$BACKUPDIR"/sql"; # Make SQL Dir in Temp Dir
for db in ${MYSQLDBS[*]}; do
    # Dump selected databases into their own respective file in the SQL folder
    DUMPDIR=`echo $TMPDIR$BACKUPDIR"/sql/"$db".sql"`;
    docker exec $MYSQLCONTAINER sh -c `echo 'exec mysqldump --databases ' $db ' -uroot -p"$MYSQL_ROOT_PASSWORD"'` > "$DUMPDIR";
done

cd $TMPDIR;
tar -zcf $BACKUPDIR".tar.gz" $BACKUPDIR  # Compress the folder in preparation of the Glacier Upload

if [ $SANDBOX -eq "false" ]; then
    echo "Uploading "$BACKUPDIR".tar.gz to Glacier"
    java -jar glacieruploader.jar --endpoint $ENDPOINT --vault $VAULT --credentials $CREDENTAILS --multipartupload $BACKUPDIR".tar.gz" --partsize $PARTSIZE

    # Clean Up copies and ZIP file
    rm -rf $TMPDIR
    rm -f $BACKUPDIR".tar.gz"
fi

if [ !($SANDBOX -eq "false")]; then
    echo "Sandox mode is active, skipping upload and delete"
fi
