#!/bin/bash

# Options
DATA_PARTITION="/data"
STOP_CLEAN_PERCENTAGE="75"
DID_CLEAN=false
MAX_KEEP=21

# Keep a maximum of $MAX_KEEP files
TOTAL=`curl --silent 'localhost:9200/_cat/indices?v' |egrep -o "logstash-[0-9\.]*" | wc -l`
while [ ${TOTAL} -gt ${MAX_KEEP} ]; do
        OLDEST=`curl --silent 'localhost:9200/_cat/indices?v' |egrep -o "logstash-[0-9\.]*" |sort |head -1`
        #read -p "About to delete ${OLDEST}, press any key to continue"
        curl --silent -XDELETE "localhost:9200/${OLDEST}?pretty" >/dev/null
        DID_CLEAN=true
        TOTAL=$(($TOTAL-1))
done

# Allow a maximum filesystem usage of $STOP_CLEAN_PERCENTAGE
USED_PERCENTAGE=`df |grep "${DATA_PARTITION}" |awk -F" " '{ print $5 }' | sed 's/%//'`
while [ ${USED_PERCENTAGE} -gt ${STOP_CLEAN_PERCENTAGE} ]; do
        OLDEST=`curl --silent 'localhost:9200/_cat/indices?v' |egrep -o "logstash-[0-9\.]*" |sort |head -1`
        #read -p "About to delete ${OLDEST}, press any key to continue"
        curl --silent -XDELETE "localhost:9200/${OLDEST}?pretty" >/dev/null
        USED_PERCENTAGE=`df |grep "${DATA_PARTITION}" |awk -F" " '{ print $5 }' | sed 's/%//'`
        DID_CLEAN=true
done

# Actually purge the deleted data to free up space
if [ "${DID_CLEAN}" = true ]; then
        curl --silent -XPOST 'http://localhost:9200/_optimize?only_expunge_deletes=true' >/dev/null
