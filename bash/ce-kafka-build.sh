#!/usr/bin/env bash

# Reference: https://confluent.slack.com/archives/CHKMBUC8Z/p1652105200128359?thread_ts=1651879674.672189&cid=CHKMBUC8Z

set -euxo pipefail

description=${1:?}

RED=$(/usr/bin/tput setaf 1)
GREEN=$(/usr/bin/tput setaf 2)
RESET=$(/usr/bin/tput sgr0)

echo_green() {
    echo "${GREEN}$1${RESET}"
}

echo_red() {
    echo "${RED}$1${RESET}"
}

on_exit() {
    echo_red "Exit the build process due to error"
}

trap on_exit ERR

CE_KAFKA_LOCAL_REPO_DIR=/Users/fzheng/github.com/confluentinc/ce-kafka
CE_KAFKA=confluentinc/ce-kafka
CC_TROGDOR=confluentinc/cc-trogdor

current=$(date +%s);

# vault login if necessary
unset VAULT_TOKEN
modified=$(/usr/bin/stat -f %m ${HOME}/.vault-token)
if [[ $((current - modified)) -gt 3600 ]]; then
    /opt/homebrew/bin/vault login -address=https://vault.cireops.gcp.internal.confluent.cloud -method=oidc -path=okta
fi

# Build ce-kafka image and push
cd ${CE_KAFKA_LOCAL_REPO_DIR}
./gradlew clean
/usr/bin/git clean -xdf
/usr/bin/make clean-all

VERSION=$(/usr/bin/git describe --tags --always)
if ! [[ ${VERSION} =~ ^v[0-9.-]+-ce-[0-9a-zA-Z-]+$ ]]; then
    echo_red "Unexpected version: ${VERSION}"
    exit 1
else
    echo_green "Version: ${VERSION}"
fi
suffix=$(/usr/bin/basename ${HOME})-${description}-SNAPSHOT

echo_green "########## Building ce-kafka ##########"
./mk-include/bin/vault-sem-get-secret cloud_apt_script_ro
ce_kafka_image_tag=$(DOCKER_BUILDKIT=1 DOCKER_BUILD_OPTIONS="--secret id=s3auth,src=/tmp/s3auth.conf" /usr/bin/make build-docker 2>&1 |
    /usr/bin/tee /dev/tty | /usr/bin/sed -nr 's|.* IMAGE_VERSION=(.*) ARCH=amd64|\1|p')

# ECR login into cc-devel-1
AWS_ACCOUNT_ID_CC_DEVEL=037803949979
AWS_PROFILE_CC_DEVEL=cc-devel-1/nonprod-administrator
AWS_ECR_CC_DEVEL=${AWS_ACCOUNT_ID_CC_DEVEL}.dkr.ecr.us-west-2.amazonaws.com/${CE_KAFKA}:${VERSION}-${suffix}
/usr/local/bin/aws ecr get-login-password --region us-west-2 --profile ${AWS_PROFILE_CC_DEVEL} | \
    /usr/local/bin/docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID_CC_DEVEL}.dkr.ecr.us-west-2.amazonaws.com

if [[ "${ce_kafka_image_tag}" == "${VERSION}" ]]; then
    echo_green "push ce-kafka to ${AWS_ACCOUNT_ID_CC_DEVEL} ECR: ${CE_KAFKA}:${VERSION}-${suffix}"
    /usr/local/bin/docker tag ${CE_KAFKA}:${VERSION}-amd64 ${AWS_ECR_CC_DEVEL}
    /usr/local/bin/docker push ${AWS_ECR_CC_DEVEL}
    # /opt/homebrew/bin/aws ecr list-images --profile ${AWS_PROFILE_CC_DEVEL} --region us-west-2 --repository-name ${CE_KAFKA} | grep ${VERSION}-${suffix}
else
    echo_red "Unexpected ce-kafka image tag: ${ce_kafka_image_tag}"
    exit 1
fi

# ECR login into cc-internal-devprod-prod-1 (519856050701)
# AWS_ACCOUNT_ID_DEVPROD=519856050701
# AWS_PROFILE_DEVPROD=cc-internal-devprod-prod-1/developer-reader
# AWS_ECR_DEVPROD=${AWS_ACCOUNT_ID_DEVPROD}.dkr.ecr.us-west-2.amazonaws.com/docker/prod/${CE_KAFKA}:${VERSION}-${suffix}
# /opt/homebrew/bin/aws ecr get-login-password --region us-west-2 --profile ${AWS_PROFILE_DEVPROD} | \
#     /usr/local/bin/docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID_DEVPROD}.dkr.ecr.us-west-2.amazonaws.com

# echo_green "push ce-kafka to ${AWS_ACCOUNT_ID_DEVPROD} ECR: docker/prod/${CE_KAFKA}:${VERSION}-${suffix}"
# /usr/local/bin/docker tag ${CE_KAFKA}:${VERSION}-amd64 ${AWS_ECR_DEVPROD}
# /usr/local/bin/docker push ${AWS_ECR_DEVPROD}


# Build cc-trogdor and push
# /opt/homebrew/bin/aws ecr get-login-password --region us-west-2 --profile ${AWS_PROFILE_DEVPROD} | \
#     /usr/local/bin/docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID_DEVPROD}.dkr.ecr.us-west-2.amazonaws.com

# echo_green "########## Building cc-trogdor ##########"
# /usr/bin/make -C cc-services/trogdor clean || true
# ./mk-include/bin/vault-sem-get-secret cloud_apt_script_ro
# Use ce-kafka image we just built and pushed as the base for Trogdor
# cc_trogdor_image_tag=$(DOCKER_BUILD_OPTIONS="--build-arg base_version=${VERSION}-${suffix}" /usr/bin/make -C cc-services/trogdor build-docker 2>&1 |
#     /usr/bin/tee /dev/tty | /usr/bin/sed -nr 's|.* naming to docker.io/(.*) done.*|\1|p')

# if [[ "${cc_trogdor_image_tag}" == "${CC_TROGDOR}:${VERSION}" ]]; then
#     echo_green "push cc-trogdor to ${AWS_ACCOUNT_ID_DEVPROD} ECR: docker/prod/${CC_TROGDOR}:${VERSION}-${suffix}"
#     /usr/local/bin/docker tag ${CC_TROGDOR}:${VERSION} ${AWS_ACCOUNT_ID_DEVPROD}.dkr.ecr.us-west-2.amazonaws.com/docker/prod/${CC_TROGDOR}:${VERSION}-${suffix}
#     /usr/local/bin/docker push ${AWS_ACCOUNT_ID_DEVPROD}.dkr.ecr.us-west-2.amazonaws.com/docker/prod/${CC_TROGDOR}:${VERSION}-${suffix}
# else
#     echo_red "Unexpected cc-trogdor image tag: ${cc_trogdor_image_tag}"
#     exit 1
# fi

# Also push the cc-trogdor image to cc-devel-1
# /opt/homebrew/bin/aws ecr get-login-password --region us-west-2 --profile ${AWS_PROFILE_CC_DEVEL} | \
#     /usr/local/bin/docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID_CC_DEVEL}.dkr.ecr.us-west-2.amazonaws.com

# echo_green "push cc-trogdor to ${AWS_ACCOUNT_ID_CC_DEVEL} ECR: ${CC_TROGDOR}:${VERSION}-${suffix}"
# /usr/local/bin/docker tag ${CC_TROGDOR}:${VERSION} ${AWS_ACCOUNT_ID_CC_DEVEL}.dkr.ecr.us-west-2.amazonaws.com/${CC_TROGDOR}:${VERSION}-${suffix}
# /usr/local/bin/docker push ${AWS_ACCOUNT_ID_CC_DEVEL}.dkr.ecr.us-west-2.amazonaws.com/${CC_TROGDOR}:${VERSION}-${suffix}
# /opt/homebrew/bin/aws ecr list-images --profile ${AWS_PROFILE_CC_DEVEL} --region us-west-2 --repository-name ${CC_TROGDOR} | grep ${VERSION}-${suffix}

echo_green "Succeed!"