# required ENV variables
# CONTAINER_NAME - name of container which generates log
# BK_BUCKET - bucket to which file should be copied
# logs folder should be mounted as /logs
export BK_YEAR=`date '+%Y'`
export BK_MONTH=`date '+%m'`
export BK_DAY=`date '+%d'`
export BK_SUFFIX=`date '+%Y%m%d-%H%M%S'`
VM_NAME=$(curl --silent -H Metadata-Flavor:Google http://metadata.google.internal/computeMetadata/v1/instance/hostname | cut -d. -f1)
echo instance name is $VM_NAME
CONTAINER_ID=$(docker ps  | grep $CONTAINER_NAME | cut -d' ' -f1)
echo sending USR1 signal to container $CONTAINER_ID
JSON_FILE=$VM_NAME-logs-$BK_SUFFIX.json
echo output file $JSON_FILE
mv /logs/logs.json /logs/$JSON_FILE
docker kill --signal=USR1 $CONTAINER_ID
gzip /logs/$JSON_FILE
gcloud auth activate-service-account --key-file=/gcloud-auth.json
gsutil -q cp /logs/$JSON_FILE.gz gs://$BK_BUCKET/$BK_YEAR/$BK_MONTH/$BK_DAY/
rm /logs/$JSON_FILE.gz
