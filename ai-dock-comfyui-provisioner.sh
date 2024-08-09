#!/bin/bash

# This file will be sourced in init.sh

# Download link for this file:
# https://raw.githubusercontent.com/jordancoult/cog-comfyui/develop/ai-dock-comfyui-provisioner.sh

# List of models available to fofr workflow auto-download stuff
# https://github.com/fofr/cog-comfyui/blob/main/supported_weights.md

# Install what we need to parse files
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

WORKFLOW_API_URL="https://raw.githubusercontent.com/jordancoult/cog-consistent-character/develop/workflow_api.json"
# CUSTOM_NODES_URL="https://raw.githubusercontent.com/jordancoult/cog-consistent-character/develop/custom_nodes.json"
CUSTOM_NODES_URL="https://raw.githubusercontent.com/jordancoult/cog-comfyui/develop/custom_nodes.json"
COG_URL="https://raw.githubusercontent.com/jordancoult/cog-consistent-character/develop/cog.yaml"

# Clone the ComfyUI repo
export REPO_NAME="cog-comfyui"
git clone -b develop https://github.com/jordancoult/$REPO_NAME.git "$WORKSPACE/$REPO_NAME"

PYTHON_PACKAGES=(
    "ultralytics!=8.0.177"
)
# packages in cog appended to this

# Nodes are manually set with those specified in consistent-character (disregarding commits)
NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
    # "https://github.com/cubiq/ComfyUI_IPAdapter_plus"
    # "https://github.com/Fannovel16/comfyui_controlnet_aux"
    # "https://github.com/cubiq/ComfyUI_essentials"
    # "https://github.com/cubiq/ComfyUI_InstantID"
    # "https://github.com/ZHO-ZHO-ZHO/ComfyUI-BRIA_AI-RMBG"
    # "https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes"
    # "https://github.com/huchenlei/ComfyUI-layerdiffuse"
    # "https://github.com/kijai/ComfyUI-KJNodes"
    # "https://github.com/huchenlei/ComfyUI-IC-Light-Native"
    # "https://github.com/fofr/ComfyUI-Impact-Pack"
    # "https://github.com/WASasquatch/was-node-suite-comfyui"
)

CHECKPOINT_MODELS=(
    #"https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.ckpt"
    #"https://huggingface.co/stabilityai/stable-diffusion-2-1/resolve/main/v2-1_768-ema-pruned.ckpt"
    #"https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors"
    #"https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors"
)

LORA_MODELS=(
    #"https://civitai.com/api/download/models/16576"
)

VAE_MODELS=(
    "https://huggingface.co/stabilityai/sd-vae-ft-ema-original/resolve/main/vae-ft-ema-560000-ema-pruned.safetensors"
    "https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors"
    "https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors"
)

ESRGAN_MODELS=(
    "https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x4.pth"
    "https://huggingface.co/FacehugmanIII/4x_foolhardy_Remacri/resolve/main/4x_foolhardy_Remacri.pth"
    "https://huggingface.co/Akumetsu971/SD_Anime_Futuristic_Armor/resolve/main/4x_NMKD-Siax_200k.pth"
)

CONTROLNET_MODELS=(
    "https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_canny-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_depth-fp16.safetensors"
    "https://huggingface.co/kohya-ss/ControlNet-diff-modules/resolve/main/diff_control_sd15_depth_fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_hed-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_mlsd-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_normal-fp16.safetensors"
    "https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_openpose-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_scribble-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_seg-fp16.safetensors"
    "https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/t2iadapter_canny-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/t2iadapter_color-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/t2iadapter_depth-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/t2iadapter_keypose-fp16.safetensors"
    "https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/t2iadapter_openpose-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/t2iadapter_seg-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/t2iadapter_sketch-fp16.safetensors"
    #"https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/t2iadapter_style-fp16.safetensors"
)

### DO NOT EDIT BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING ###

function provisioning_start() {
    DISK_GB_AVAILABLE=$(($(df --output=avail -m "${WORKSPACE}" | tail -n1) / 1000))
    DISK_GB_USED=$(($(df --output=used -m "${WORKSPACE}" | tail -n1) / 1000))
    DISK_GB_ALLOCATED=$(($DISK_GB_AVAILABLE + $DISK_GB_USED))
    provisioning_print_header
    provisioning_get_nodes
    provisioning_get_nodes_from_json  # this broke comfyUI
    provisioning_install_python_packages
    provisioning_get_models \
        "${WORKSPACE}/storage/stable_diffusion/models/ckpt" \
        "${CHECKPOINT_MODELS[@]}"
    # provisioning_get_models \
    #     "${WORKSPACE}/storage/stable_diffusion/models/lora" \
    #     "${LORA_MODELS[@]}"
    # provisioning_get_models \
    #     "${WORKSPACE}/storage/stable_diffusion/models/controlnet" \
    #     "${CONTROLNET_MODELS[@]}"
    # provisioning_get_models \
    #     "${WORKSPACE}/storage/stable_diffusion/models/vae" \
    #     "${VAE_MODELS[@]}"
    # provisioning_get_models \
    #     "${WORKSPACE}/storage/stable_diffusion/models/esrgan" \
    #     "${ESRGAN_MODELS[@]}"
    printf "\n##############################################\n#                                            #\n#          launching installFromWorkflow script (installs custom nodes)#\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"
    install_from_workflow
    provisioning_print_end
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

function provisioning_get_nodes_from_json() {
    # Download the custom nodes JSON file
    wget $CUSTOM_NODES_URL -O "$WORKSPACE/custom_nodes.json"
    # Read the JSON content from the file into a variable
    local json_content=$(cat "$WORKSPACE/custom_nodes.json")
    # Parse the JSON content to extract the repo URLs
    local repos=$(echo "$json_content" | jq -r '.[].repo')

    for repo in $repos; do
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
    # Append cog packages to already defined python packages
    wget $COG_URL -O $WORKSPACE/downloaded_cog.yaml
    COG_PYTHON_PACKAGES=$(yq -r '.build.python_packages | join(" ")' $WORKSPACE/downloaded_cog.yaml)
    PYTHON_PACKAGES="$PYTHON_PACKAGES $COG_PYTHON_PACKAGES"
    # Install Python packages
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

function install_from_workflow() {
    # Install necessary tool
    sudo curl -o /usr/local/bin/pget -L "https://github.com/replicate/pget/releases/download/v0.8.1/pget_linux_x86_64" && sudo chmod +x /usr/local/bin/pget && echo "pget installed successfully!"
    # Download WORKFLOW_API_URL to a local file
    provisioning_download "${WORKFLOW_API_URL}" "${WORKSPACE}"
    local workflow_name=$(basename "${WORKFLOW_API_URL}")
    # rename to cons_char_workflow_api.json
    mv "${WORKSPACE}/${workflow_name}" "${WORKSPACE}/cons_char_workflow_api.json"
    # Change directory to $WORKSPACE/$REPO_NAME
    cd "${WORKSPACE}/${REPO_NAME}"
    # Run local python file installFromWorkflow.py workflow.json
    sudo python3 installFromWorkflow.py ${WORKSPACE}/cons_char_workflow_api.json
    # Optionally, change back to the previous directory if needed
    cd -
}

function provisioning_print_header() {
    printf "\n##############################################\n#                                            #\n#          Provisioning container            #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"
    if [[ $DISK_GB_ALLOCATED -lt $DISK_GB_REQUIRED ]]; then
        printf "WARNING: Your allocated disk size (%sGB) is below the recommended %sGB - Some models will not be downloaded\n" "$DISK_GB_ALLOCATED" "$DISK_GB_REQUIRED"
    fi
}

function provisioning_print_end() {
    printf "\nProvisioning complete:  Web UI will start now\n\n"
}

# Download from $1 URL to $2 file path
function provisioning_download() {
    wget -qnc --content-disposition --show-progress -e dotbytes="${3:-4M}" -P "$2" "$1"
}

provisioning_start