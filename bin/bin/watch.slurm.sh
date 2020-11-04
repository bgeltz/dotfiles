#!/bin/bash

# export SINFO_FORMAT="%P %.5a %.10l %.6D %.6t"
export SQUEUE_FORMAT="%.7i %.8u %.8j %.10M %.12l %.9L %.6D %.8T %.9P %.20S %.20V %r"
watch -n 1.0 "sinfo; echo ; echo ; squeue"
