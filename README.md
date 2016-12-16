# Elasticsearch cleanup indices
Script to cleanup Elasticsearch inidices automatically

This script is able to delete indicies older than 21 days or, when there is lots of data comming in at once, delete the oldest indices when free disk space is lower than 25 percent.

1. Place this script on the same server as where your Elasticsearch Data is located
2. do a "chmod +x" on this file
3. if you want, you can schedule this as a job.
4. my crontab -e looks like this " 0 23 * * * /etc/scripts/cleanup.sh"

www.gerhardpegel.nl
