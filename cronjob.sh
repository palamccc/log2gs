set -e
# required ENV variables
# SERVICE_NAME - name of container which generates log
# TARGET_BUCKET - bucket to which file should be copied
# LOGS_DIR - folder where log files stored
# LOGS_FILE - file which should be rotated

export BK_YEAR=`date '+%Y'`
export BK_MONTH=`date '+%m'`
export BK_DAY=`date '+%d'`
export BK_SUFFIX=`date '+%Y%m%d-%H%M%S'`

# get vm name
VM_NAME=$(curl --silent -H Metadata-Flavor:Google http://metadata.google.internal/computeMetadata/v1/instance/hostname | cut -d. -f1)
echo instance name is $VM_NAME

# move logfile to new timestamped file
cd $LOGS_DIR
OUT_FILE=$VM_NAME-$BK_SUFFIX.jsonl
echo output file $OUT_FILE
mv $LOGS_FILE $OUT_FILE

# signal container to start new log file
CONTAINER_ID=$(docker ps --filter label=com.docker.swarm.service.name=$SERVICE_NAME --format {{.ID}})
echo sending USR1 signal to container $CONTAINER_ID
docker kill --signal=USR1 $CONTAINER_ID

# copy file to gs
GS_DIR=gs://$TARGET_BUCKET/$BK_YEAR/$BK_MONTH/$BK_DAY
gcloud --no-user-output-enabled  auth activate-service-account --key-file=/gcloud-auth.json
echo copying $GS_DIR/$OUT_FILE
gsutil -q cp -Z $OUT_FILE $GS_DIR/$OUT_FILE
rm $OUT_FILE
