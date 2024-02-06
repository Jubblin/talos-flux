CONTEXTS=$(kubectl config get-contexts -o name)

for CONFIG in  $CONTEXTS;
do
  echo Executing flux Bootstrap for $CONFIG
  flux bootstrap github \
  --components-extra=image-reflector-controller,image-automation-controller \
  --context=${CONFIG} \
  --owner=${GITHUB_USER} \
  --repository=${GITHUB_REPO} \
  --branch=main \
  --personal \
  --path=clusters/${CONFIG} \
  --read-write-key
  if [ $? -eq 0 ]; then
    echo "Command succeeded"
    echo
  else
    echo "Command failed: ${?}"
  fi
done
