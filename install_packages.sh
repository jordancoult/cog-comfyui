PYTHON_PACKAGES=$(yq -r '.build.python_packages | join(" ")' $WORKSPACE/$REPO_NAME/cog.yaml)

IFS=' ' read -r -a temp_array <<< "$PYTHON_PACKAGES"
echo "Number of Python packages to install: ${#temp_array[@]}"

if [ ${#PYTHON_PACKAGES[@]} -gt 0 ]; then
    micromamba -n comfyui run ${PIP_INSTALL} ${PYTHON_PACKAGES[*]}
fi