#!/bin/bash

export SINFO_FORMAT="%P %.5a %.10l %.6D %.6t"
export SQUEUE_FORMAT="%.7i %.8u %.8j %.10M %.9l %.9L %.6D %.8T %.9P %R %N %S"
watch -n 1.0 "sinfo -p pbatch; echo ; sinfo -p pdebug ; echo ; squeue -u $(whoami)"
