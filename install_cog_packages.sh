# Install packages for cog parsing
if ! command -v jq &> /dev/null
then
    echo "jq could not be found, installing..."
    sudo apt-get update && sudo apt-get install -y jq
fi
if ! command -v yq &> /dev/null
then
    echo "yq could not be found, installing..."
    sudo wget https://github.com/mikefarah/yq/releases/download/v4.30.8/yq_linux_amd64 -O /usr/local/bin/yq
    sudo chmod +x /usr/local/bin/yq
fi

PYTHON_PACKAGES=$(yq -r '.build.python_packages | join(" ")' cog.yaml)

IFS=' ' read -r -a temp_array <<< "$PYTHON_PACKAGES"
echo "Number of Python packages to install: ${#temp_array[@]}"

if [ ${#PYTHON_PACKAGES[@]} -gt 0 ]; then
    micromamba -n comfyui run ${PIP_INSTALL} ${PYTHON_PACKAGES[*]}
fi