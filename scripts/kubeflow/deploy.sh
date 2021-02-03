# must set CLOUD, LOCATION, NAME, PROJECT, USER

# https://www.kubeflow.org/docs/gke/deploy/deploy-cli/

## Environment Variables 
export KF_NAME=${NAME}
export KF_PROJECT=${PROJECT}
export KF_DIR=.mlcli/gcp_${PROJECT}_${NAME}/configuration
export MGMT_NAME=mgmt-${NAME}
export MGMTCTXT=${MGMT_NAME}
export MANAGEMENT_CTXT=$MGMTCTXT

rm -rf ${KF_DIR}

## Fetch packages using kpt 
kpt pkg get https://github.com/kubeflow/gcp-blueprints.git/kubeflow@v1.2.0 "${KF_DIR}"
cd "${KF_DIR}"
make get-pkg

sed -i '' "s/<YOUR_MANAGEMENT_CTXT>/${MGMTCTXT}/" Makefile 
sed -i '' "s/<YOUR_KF_NAME>/${KF_NAME}/" Makefile
sed -i '' "s/<PROJECT_TO_DEPLOY_IN>/${KF_PROJECT}/" Makefile
sed -i '' "s/<YOUR PROJECT>/${KF_PROJECT}/" Makefile
sed -i '' "s/<ZONE>/${LOCATION}/" Makefile
sed -i '' "s/<REGION OR ZONE>/${LOCATION}/" Makefile
sed -i '' "s/<YOUR_REGION OR ZONE>/${LOCATION}/" Makefile
sed -i '' "s/<YOUR_REGION or ZONE>/${LOCATION}/" Makefile
sed -i '' "s/<YOUR_EMAIL_ADDRESS>/${USER}/" Makefile

kubectl config use-context "${MGMTCTXT}"
kubectl create namespace "${KF_PROJECT}"
kubectl config set-context --current --namespace "${KF_PROJECT}"

cd ${KF_DIR}/../..  # install istioctl in .mlcli/
curl -LO https://storage.googleapis.com/gke-release/asm/istio-1.4.10-asm.18-osx.tar.gz
curl -LO https://storage.googleapis.com/gke-release/asm/istio-1.4.10-asm.18-osx.tar.gz.1.sig
openssl dgst -sha256 -verify /dev/stdin -signature istio-1.4.10-asm.18-osx.tar.gz.1.sig istio-1.4.10-asm.18-osx.tar.gz <<'EOF'
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEWZrGCUaJJr1H8a36sG4UUoXvlXvZ
wQfk16sxprI2gOJ2vFFggdq3ixF2h4qNBt0kI7ciDhgpwS8t+/960IsIgw==
-----END PUBLIC KEY-----
EOF
tar xzf istio-1.4.10-asm.18-osx.tar.gz

cd istio-1.4.10-asm.18
export PATH=$PWD/bin:$PATH
