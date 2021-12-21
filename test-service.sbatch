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

test_list="TestIntegration_omp_outer_loop \
           TestIntegration_enforce_policy \
           TestIntegration_profile_policy \
           TestIntegration_plugin_static_policy \
           TestIntegration_frequency_hint_usage \
           TestIntegration_profile_overflow \
           TestIntegration_trace \
           TestIntegration_monitor \
           TestIntegration_geopmio \
           TestIntegration_ompt \
           TestIntegration_launch_application \
           TestIntegration_launch_pthread \
           TestIntegration_geopmagent \
           TestIntegration_environment \
           TestIntegration_frequency_map \
           TestIntegration_hint_time \
           TestIntegration_progress \
           TestIntegration_programmable_counters"
long_test="TestIntegration_ee_timed_scaling_mix \
           TestIntegration_power_balancer \
           TestIntegration_power_governor \
           TestIntegration_scaling_region \
           TestIntegration_timed_scaling_region \
           TestIntegration_tutorial_base"
if [ ! -z "$GEOPM_RUN_LONG_TESTS" ]; then
    test_list="$test_list $long_test"
fi

failed=''
for tt in ${test_list}; do
    logfile=$(echo ${tt} | sed -e 's|TestIntegration|test|').py.log
    python3 ${GEOPM_SOURCE}/integration/test ${tt} >& ${logfile}
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
