#!/bin/bash -l

path_to_link(){
    local SHORT_PATH="$(realpath --no-symlinks --relative-base ${HOME}/public_html ${1})"
    local LOG_URL="${TEST_OUTPUT_URL}/${SHORT_PATH}"
    echo "${LOG_URL}"
}

check_rc(){
    local RC=$?
    local ERR_MSG=${1}
    local LOG_URL=$(path_to_link ${2})

    if [ ${RC} -ne 0 ]; then
        # Remove ' and " from ERR_MSG
        ERR_MSG=${ERR_MSG//\'/}
        ERR_MSG=${ERR_MSG//\"/}
        notify.sh "Code coverage failure : ${TIMESTAMP}" "${ERR_MSG}\n${LOG_URL}"
        exit ${RC}
    fi
}

echo '######################################################################'
echo "# BEGIN: $(basename ${0}) - $(date)"
echo '######################################################################'

# Load modules
module purge
module load gnu9 mpich autotools cmake ccache

# Setup output dirs
export TIMESTAMP=$(date +\%F_\%H\%M)
LOG_DIR=${HOME}/public_html/coverage_runs/${TIMESTAMP}
mkdir -p ${LOG_DIR}
ln -sfn ${LOG_DIR} $(dirname ${LOG_DIR})/latest

# Setup build environment - GNU w/override
source ${HOME}/geopm/integration/config/gnu_env.sh
GEOPM_SKIP_COMPILER_CHECK=yes source ${HOME}/geopm/integration/config/build_env.sh

# Assume the branch history was setup correctly in test_legacy.sh
cd ${GEOPM_SOURCE}
git clean -ffdx --quiet
rm -fr ${GEOPM_INSTALL}

GEOPM_SKIP_COMPILER_CHECK=yes \
GEOPM_SKIP_SERVICE_INSTALL=yes \
GEOPM_SKIP_BASE_INSTALL=yes \
GEOPM_GLOBAL_CONFIG_OPTIONS="--enable-coverage" \
./integration/config/build.sh \
> ${LOG_DIR}/build_gnu_release.out \
2> ${LOG_DIR}/build_gnu_release.err
check_rc "GNU build failed" "${LOG_DIR}/build_gnu_release.err"

# Use source build of lcov to resolve: https://github.com/linux-test-project/lcov/issues/58
#    The version in zypper is too old
export PATH=${HOME}/build/lcov/bin:${PATH}

# "make coverage" is not used here so that both the base and service directories can
# be captured together, and ultimately have a unified report website at the end

# Initial / baseline lcov
DIRECTORY_LIST="--directory src --directory test --directory service/src --directory service/test"
lcov --capture --initial ${DIRECTORY_LIST} \
     --output-file base_coverage.info --no-external \
> ${LOG_DIR}/coverage.out \
2> ${LOG_DIR}/coverage.err
check_rc "lcov initial capture failed" "${LOG_DIR}/coverage.err"

# Begin the job
cd ${LOG_DIR}

# Run integration tests
sbatch --wait test_legacy.sbatch gnu

# Go back to the source dir
cd ${GEOPM_SOURCE}

# Build/run unit tests
cd service
make -j9 checkprogs \
> ${LOG_DIR}/checkprogs_service.out \
2> ${LOG_DIR}/checkprogs_service.err

make check \
> ${LOG_DIR}/check_service.out \
2> ${LOG_DIR}/check_service.err

cd ..

make -j9 checkprogs \
> ${LOG_DIR}/checkprogs_base.out \
2> ${LOG_DIR}/checkprogs_base.err

make check \
> ${LOG_DIR}/checkprogs_base.out \
2> ${LOG_DIR}/checkprogs_base.err

######################################################################################
echo "lcov - Coverage capture" >> ${LOG_DIR}/coverage.out
lcov --no-external --capture ${DIRECTORY_LIST} \
     --output-file coverage.info \
> ${LOG_DIR}/coverage.out \
2> ${LOG_DIR}/coverage.err

echo "lcov - Baseline/Coverage combine" >> ${LOG_DIR}/coverage.out
lcov --rc lcov_branch_coverage=1 \
     -a base_coverage.info -a coverage.info \
     -o combined_coverage.info \
> ${LOG_DIR}/coverage.out \
2> ${LOG_DIR}/coverage.err

echo "lcov - Combined coverage filter" >> ${LOG_DIR}/coverage.out
lcov --rc lcov_branch_coverage=1 \
     --remove combined_coverage.info "$(pwd)/test*" "$(pwd)/service/test*" \
                                     "$(pwd)/contrib*" "$(pwd)/src/geopm_pmpi_fortran.c" \
                                     "$(pwd)/gmock*" "/opt*" "/usr*" "5.3.0*" \
     -o filtered_coverage.info \
> ${LOG_DIR}/coverage.out \
2> ${LOG_DIR}/coverage.err

echo "genhtml - Webpage construction" >> ${LOG_DIR}/coverage.out
genhtml filtered_coverage.info \
        --output-directory coverage \
        --legend -t "$(git describe) w/beta flag" -f \
> ${LOG_DIR}/coverage.out \
2> ${LOG_DIR}/coverage.err

# Copy coverage html to date stamped public_html dir
cp -rp coverage ${LOG_DIR}

# Copy unit and integration test outputs to dir
cp -rp --parents service/test/gtest_links ${LOG_DIR}
cp -rp --parents service/geopmdpy_test/pytest_links ${LOG_DIR}
cp -rp --parents scripts/test/pytest_links ${LOG_DIR}
cp -rp --parents test/gtest_links ${LOG_DIR}

FILES=\
"*info* "\
"*log* "\
"*out* "\

set +e
for f in $(ls -I "*h5" ${FILES});
do
    cp -p --parents ${f} ${LOG_DIR}
done
set -e

RDY_MSG="The coverage report is ready:\n${TEST_OUTPUT_URL}/coverage_runs/${TIMESTAMP}/coverage\n\nAdditional data available in parent directory."
echo -e ${RDY_MSG}  | mail -r "do-not-reply" -s "Coverage report ready : ${TIMESTAMP}" ${MAILING_LIST}
notify.sh "Code coverage : ${TIMESTAMP}" "${RDY_MSG}"

# End nightly coverage report generation
########################################
