#!/bin/bash

#### Initial variables ####

# Max of backups to keep
max_days=3

# root direcroty for backup
dir=$PWD

# file name prefix
prefix="backup"

now=$(date +"%d%m%Y")
old=$(date --date="${max_days} days ago" +"%d%m%Y")

oldsqlfile="${prefix}_mysql_${old}.sql.gz"
newsqlfile="${prefix}_mysql_${now}.sql.gz"

oldwebfile="${prefix}_web_${old}.tar"
newwebfile="${prefix}_web_${now}.tar"

oldsqlfilepath="${dir}/backup/mysql/${oldsqlfile}"
newsqlfilepath="${dir}/backup/mysql/${newsqlfile}"

oldwebfilepath="${dir}/backup/web/${oldwebfile}"
newwebfilepath="${dir}/backup/web/${newwebfile}"

if [ ! -d $dir/backup/mysql/ ]; then
    mkdir -p $dir/backup/mysql/
fi

if [ ! -d $dir/backup/web/ ]; then
    mkdir -p $dir/backup/web/
fi

if [ -f $oldsqlfilepath ];
then
    rm $oldsqlfilepath
    echo "Deleted $oldsqlfilepath"
fi

if [ -f $oldwebfilepath ];
then
    rm $oldwebfilepath
    echo "Deleted $oldwebfilepath"
fi


if [ -f $newsqlfilepath ];
then
    echo "Last database backup file already exists"
else
    docker exec wp-database sh -c 'exec mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" ${MYSQL_DATABASE}' | gzip -9 > $newsqlfilepath
    echo "Created $newsqlfilepath"

fi

if [ -f $newwebfilepath ];
then
    echo "Last web backup file already exists"
else
    tar -cf $newwebfilepath --exclude-from=$dir"/backup-exclude.txt" -C $dir wordpress
    echo "Created $newwebfilepath"
fi