#!/bin/bash
#SBATCH -N 4
#SBATCH -t 12:00:00
#SBATCH -o /home/test-service/test-service.sbatch.log
#SBATCH -e /home/test-service/test-service.sbatch.log

#export GEOPM_RUN_LONG_TESTS=TRUE
unset GEOPM_RUN_LONG_TESTS

export GEOPM_SOURCE=/home/test-service/geopm-cmcantal
export GEOPM_INSTALL=/home/test-service/build/geopm-cmcantal
export LD_LIBRARY_PATH=${GEOPM_INSTALL}/lib:${LD_LIBRARY_PATH}
export PYTHONPATH=${GEOPM_INSTALL}/lib/python3.6/site-packages:${PYTHONPATH}
export PATH=${GEOPM_INSTALL}/bin:${PATH}
GEOPM_VERSION=$(cat ${GEOPM_SOURCE}/service/VERSION)

# Install geopm-service RPMs
INSTALL_COMMAND="sudo /usr/sbin/install_service.sh ${GEOPM_VERSION} ${USER}"
srun -w ${SLURM_NODELIST} -N ${SLURM_NNODES} -n ${SLURM_NNODES} ${INSTALL_COMMAND}

test_list="${GEOPM_SOURCE}/integration/test/test_omp_outer_loop.py \
           ${GEOPM_SOURCE}/integration/test/test_enforce_policy.py \
           ${GEOPM_SOURCE}/integration/test/test_profile_policy.py \
           ${GEOPM_SOURCE}/integration/test/test_plugin_static_policy.py \
           ${GEOPM_SOURCE}/integration/test/test_tutorial_base.py \
           ${GEOPM_SOURCE}/integration/test/test_frequency_hint_usage.py \
           ${GEOPM_SOURCE}/integration/test/test_profile_overflow.py \
           ${GEOPM_SOURCE}/integration/test/test_trace.py \
           ${GEOPM_SOURCE}/integration/test/test_monitor.py \
           ${GEOPM_SOURCE}/integration/test/test_geopmio.py \
           ${GEOPM_SOURCE}/integration/test/test_ompt.py \
           ${GEOPM_SOURCE}/integration/test/test_launch_application.py \
           ${GEOPM_SOURCE}/integration/test/test_launch_pthread.py \
           ${GEOPM_SOURCE}/integration/test/test_geopmagent.py \
           ${GEOPM_SOURCE}/integration/test/test_environment.py \
           ${GEOPM_SOURCE}/integration/test/test_frequency_map.py \
           ${GEOPM_SOURCE}/integration/test/test_hint_time.py \
           ${GEOPM_SOURCE}/integration/test/test_progress.py \
           ${GEOPM_SOURCE}/integration/test/test_programmable_counters.py"
long_test="${GEOPM_SOURCE}/integration/test/test_ee_timed_scaling_mix.py \
           ${GEOPM_SOURCE}/integration/test/test_power_balancer.py \
           ${GEOPM_SOURCE}/integration/test/test_power_governor.py \
           ${GEOPM_SOURCE}/integration/test/test_scaling_region.py \
           ${GEOPM_SOURCE}/integration/test/test_timed_scaling_region.py"
if [ ! -z "$GEOPM_RUN_LONG_TESTS" ]; then
    test_list="$test_list $long_test"
fi

failed=''
for tt in ${test_list}; do
    logfile=$(basename ${tt}).log
    python3 ${tt} >& ${logfile}
    if [ $? -ne 0 ]; then
        failed="${failed} ${tt}"
    fi
done

if [ -z "${failed}" ]; then
    exit 0
else
    echo "FAILED:${failed}" 1>&2
    exit -1
fi
