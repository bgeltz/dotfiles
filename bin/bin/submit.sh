#!/bin/bash
set -e

export JOBID=$(sbatch ${1} | cut -d' ' -f 4)
if [ -z "${JOBID}" ]
then
    exit 1
fi

echo "Job ${JOBID} queued at $(date +%F_%H%M.%S)..."

# Wait for job log to appear
JOB_LOG=${HOME}/output/${JOBID}*.out
until [ -f ${JOB_LOG} ]; do sleep 2; done

# Start a bg tail to watch job output
tail -f ${JOB_LOG} 2> /dev/null &

# Backup current job script
OUTPUT_DIR=$(ls -d ${HOME}/output/${JOBID}* | head -n1)
cp ${1} ${OUTPUT_DIR}

while squeue -u ${USER} | grep ${JOBID} &> /dev/null; do sleep 5; done
echo "Job ${JOBID} finished at $(date +%F_%H%M.%S)..."

# notify.sh "Job ${JOBID} Complete!" &> /dev/null
echo "Job ${JOBID} complete!"

kill %1 2>&1 > /dev/null
wait > /dev/null 2>&1

# Backup job output log
cp ${HOME}/output/${JOBID}*.out ${OUTPUT_DIR}
