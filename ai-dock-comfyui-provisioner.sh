#!/bin/bash

# This file will be sourced in init.sh

# https://raw.githubusercontent.com/jordancoult/cog-comfyui/develop/ai-dock-comfyui-provisioner.sh

# Packages are installed after nodes so we can fix them...

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

# Install other required Ubuntu packages into micromamba env
# Replicate/pget
sudo curl -o /opt/micromamba/envs/comfyui/bin/pget -L "https://github.com/replicate/pget/releases/latest/download/pget_$(uname -s)_$(uname -m)"
sudo chmod +x /opt/micromamba/envs/comfyui/bin/pget

# Clone the ComfyUI repo (credential expires in September 2024)
export REPO_NAME="cog-comfyui"
git clone -b develop https://github.com/jordancoult/$REPO_NAME.git "$WORKSPACE/$REPO_NAME"

# Get python packages from cog.yaml
PYTHON_PACKAGES=$(yq -r '.build.python_packages | join(" ")' $WORKSPACE/$REPO_NAME/cog.yaml)

# # Set specific python version from cog.yaml
# PYTHON_VERSION=$(yq e '.build.python_version' -o=json cog.yaml | jq -r '.')
# # Install the specific Python version using pyenv
# if ! pyenv versions | grep -q "$PYTHON_VERSION"; then
#     echo "Installing Python $PYTHON_VERSION with pyenv..."
#     pyenv install "$PYTHON_VERSION"
# fi
# # Set the local Python version
# pyenv local "$PYTHON_VERSION"
# # Verify the Python version
# python --version

NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
)
# Nodes specified in custom_nodes.json will also be installed

WORKFLOW_API_URL="https://raw.githubusercontent.com/fofr/cog-consistent-character/main/workflow_api.json"
WORKFLOW_UI_URL="https://raw.githubusercontent.com/fofr/cog-consistent-character/main/workflow_ui.json"


CHECKPOINT_MODELS=(
    #"https://huggingface.co/Lykon/dreamshaper-xl-lightning/resolve/main/DreamShaperXL_Lightning.safetensors"
    #"https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.ckpt"
    #"https://huggingface.co/stabilityai/stable-diffusion-2-1/resolve/main/v2-1_768-ema-pruned.ckpt"
    #"https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors"
    #"https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors"
)

LORA_MODELS=(
    #"https://civitai.com/api/download/models/16576"
)

VAE_MODELS=(
    #"https://huggingface.co/stabilityai/sd-vae-ft-ema-original/resolve/main/vae-ft-ema-560000-ema-pruned.safetensors"
    #"https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors"  # RV5.1
    #"https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors"
)

ESRGAN_MODELS=(
    #"https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x4.pth"
    #"https://huggingface.co/FacehugmanIII/4x_foolhardy_Remacri/resolve/main/4x_foolhardy_Remacri.pth"
    #"https://huggingface.co/Akumetsu971/SD_Anime_Futuristic_Armor/resolve/main/4x_NMKD-Siax_200k.pth"
)

CONTROLNET_MODELS=(
    #"https://huggingface.co/Aitrepreneur/InstantID-Controlnet/blob/main/checkpoints/ControlNetModel/diffusion_pytorch_model.safetensors"  # instantid-controlnet
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_canny-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_depth-fp16.safetensors"
    #"https://huggingface.co/kohya-ss/ControlNet-diff-modules/resolve/main/diff_control_sd15_depth_fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_hed-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_mlsd-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_normal-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_openpose-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_scribble-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_seg-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/t2iadapter_canny-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/t2iadapter_color-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/t2iadapter_depth-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/t2iadapter_keypose-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/t2iadapter_openpose-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/t2iadapter_seg-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/t2iadapter_sketch-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/t2iadapter_style-fp16.safetensors"
)

# https://github.com/huxiuhan/ComfyUI-InstantID
INSTANTID_MODELS=(
    #"https://huggingface.co/InstantX/InstantID/resolve/main/ip-adapter.bin"
    # "https://huggingface.co/InstantX/InstantID/resolve/main/ControlNetModel/diffusion_pytorch_model.safetensors"
    # "https://huggingface.co/InstantX/InstantID/resolve/main/ControlNetModel/config.json"
)

### DO NOT EDIT BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING ###

function provisioning_start() {
    printf "Checking disk space..."
    DISK_GB_AVAILABLE=$(($(df --output=avail -m "${WORKSPACE}" | tail -n1) / 1000))
    DISK_GB_USED=$(($(df --output=used -m "${WORKSPACE}" | tail -n1) / 1000))
    DISK_GB_ALLOCATED=$(($DISK_GB_AVAILABLE + $DISK_GB_USED))
    provisioning_print_header
    printf "\n##############################################\n#                                            #\n#          Provisioning_get_nodes                                      #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"
    provisioning_get_nodes  # get nodes listed above
    printf "\n##############################################\n#                                            #\n#          Provisioning_get_nodes_from_json (from custom_nodes.json)   #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"
    provisioning_get_nodes_from_json  # get nodes from local JSON file
    printf "\n##############################################\n#                                            #\n#          install_python_packages (from cog)                          #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"
    provisioning_install_python_packages
    # printf "Getting Stable Diffusion checkpoint models..."
    # provisioning_get_models \
    #     "${WORKSPACE}/storage/stable_diffusion/models/ckpt" \
    #     "${CHECKPOINT_MODELS[@]}"
    # printf "Getting Stable Diffusion LoRA models..."
    # provisioning_get_models \
    #     "${WORKSPACE}/storage/stable_diffusion/models/lora" \
    #     "${LORA_MODELS[@]}"
    # printf "Getting Stable Diffusion ControlNet models..."
    # provisioning_get_models \
    #     "${WORKSPACE}/storage/stable_diffusion/models/controlnet" \
    #     "${CONTROLNET_MODELS[@]}"
    # printf "Getting Stable Diffusion VAE models..."
    # provisioning_get_models \
    #     "${WORKSPACE}/storage/stable_diffusion/models/vae" \
    #     "${VAE_MODELS[@]}"
    # printf "Getting Stable Diffusion ESRGAN models..."
    # provisioning_get_models \
    #     "${WORKSPACE}/storage/stable_diffusion/models/esrgan" \
    #     "${ESRGAN_MODELS[@]}"
    # provisioning_get_models \
    #     "${WORKSPACE}/storage/stable_diffusion/models/instantid" \
    #     "${INSTANTID_MODELS[@]}"
    printf "\n##############################################\n#                                            #\n#          launching installFromWorkflow script (installs custom nodes)#\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"
    install_from_workflow
    provisioning_print_end
    printf "Provisioning complete."
}

function install_from_workflow() {
    # Download WORKFLOW_API_URL to a local file
    provisioning_download "${WORKFLOW_API_URL}" "${WORKSPACE}"
    local workflow_name=$(basename "${WORKFLOW_API_URL}")
    # rename to downloaded_workflow.json
    mv "${WORKSPACE}/${workflow_name}" "${WORKSPACE}/downloaded_workflow.json"
    # Change directory to $WORKSPACE/$REPO_NAME
    cd "${WORKSPACE}/${REPO_NAME}"
    # Run local python file installFromWorkflow.py workflow.json
    micromamba -n comfyui run python3 installFromWorkflow.py ${WORKSPACE}/downloaded_workflow.json
    # Optionally, change back to the previous directory if needed
    cd -
}

function provisioning_get_nodes_from_json() {
    # Use cat to read the JSON content from a file into a variable
    local json_content=$(cat "$WORKSPACE/$REPO_NAME/custom_nodes.json")  # todo: the reseource doesnt exist yet

    # Parse the JSON content directly from the variable
    local repos=$(printf "$json_content" | jq -c '.[]')

    for row in $repos; do
        local repo=$(printf $row | jq -r '.repo')
        local commit=$(printf $row | jq -r '.commit')
        local dir="${repo##*/}"
        local path="/opt/ComfyUI/custom_nodes/${dir}"
        local requirements="${path}/requirements.txt"

        if [[ -d $path ]]; then
            printf "Updating node: $repo..."
            (cd "$path" && git fetch && git checkout "$commit")
            if [[ -e $requirements ]]; then
                micromamba -n comfyui run ${PIP_INSTALL} -r "$requirements"
            fi
        else
            printf "Downloading node: $repo..."
            git clone "$repo" "$path" --recursive
            (cd "$path" && git checkout "$commit")
            if [[ -e $requirements ]]; then
                micromamba -n comfyui run ${PIP_INSTALL} -r "$requirements"
            fi
        fi
    done
}

function provisioning_get_nodes() {
    for repo in "${NODES[@]}"; do
        dir="${repo##*/}"
        path="/opt/ComfyUI/custom_nodes/${dir}"
        requirements="${path}/requirements.txt"
        if [[ -d $path ]]; then
            if [[ ${AUTO_UPDATE,,} != "false" ]]; then
                printf "Updating node: %s...\n" "${repo}"
                ( cd "$path" && git pull )
                if [[ -e $requirements ]]; then
                    micromamba -n comfyui run ${PIP_INSTALL} -r "$requirements"
                fi
            fi
        else
            printf "Downloading node: %s...\n" "${repo}"
            git clone "${repo}" "${path}" --recursive
            if [[ -e $requirements ]]; then
                micromamba -n comfyui run ${PIP_INSTALL} -r "${requirements}"
            fi
        fi
    done
}

function provisioning_install_python_packages() {
    IFS=' ' read -r -a temp_array <<< "$PYTHON_PACKAGES"
    echo "Number of Python packages to install: ${#temp_array[@]}"
    if [ ${#PYTHON_PACKAGES[@]} -gt 0 ]; then
        micromamba -n comfyui run ${PIP_INSTALL} ${PYTHON_PACKAGES[*]}
    fi
}

function provisioning_get_models() {
    if [[ -z $2 ]]; then return 1; fi
    dir="$1"
    mkdir -p "$dir"
    shift
    if [[ $DISK_GB_ALLOCATED -ge $DISK_GB_REQUIRED ]]; then
        arr=("$@")
    else
        printf "WARNING: Low disk space allocation - Only the first model will be downloaded!\n"
        arr=("$1")
    fi
    
    printf "Downloading %s model(s) to %s...\n" "${#arr[@]}" "$dir"
    for url in "${arr[@]}"; do
        printf "Downloading: %s\n" "${url}"
        provisioning_download "${url}" "${dir}"
        printf "\n"
    done
}

function provisioning_print_header() {
    printf "\n##############################################\n#                                            #\n#          Provisioning container            #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"
    if [[ $DISK_GB_ALLOCATED -lt $DISK_GB_REQUIRED ]]; then
        printf "WARNING: Your allocated disk size (%sGB) is below the recommended %sGB - Some models will not be downloaded\n" "$DISK_GB_ALLOCATED" "$DISK_GB_REQUIRED"
    fi
}

function provisioning_print_end() {
    printf "To prepare comfy for a new workflow manually, run the following commands, but replace the last arg with your file:\n"
    printf "micromamba -n comfyui run python3 ${WORKSPACE}${REPO_NAME}/installFromWorkflow.py ${WORKSPACE}filename.json"
    printf "\nProvisioning complete:  Web UI will start now\n\n"
}

# Download from $1 URL to $2 file path
function provisioning_download() {
    wget -qnc --content-disposition --show-progress -e dotbytes="${3:-4M}" -P "$2" "$1"
}

# todo: add import consistent char of workflow to this script

printf "Starting provisioning..."
provisioning_start