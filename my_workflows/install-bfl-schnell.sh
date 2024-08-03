# The schnell model has better prompt-following, quality, and speed the RV5.1. 
# Ex prompt: full body professional portrait of a woman, age 27, blue eyes, white shoulder-length hair, with bangs, colombian chinese, wearing casual clothes

# Define a base path for model storage
BASE_PATH="/workspace/ComfyUI/models"

# Assets
CLIP=https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors
TEXT_ENC=https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors
VAE=https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.sft
MODEL=https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/flux1-schnell.sft

# Check if pget is already installed
if ! command -v pget &> /dev/null
then
    # Install pget
    sudo curl -o /usr/local/bin/pget -L "https://github.com/replicate/pget/releases/download/v0.8.1/pget_linux_x86_64" && sudo chmod +x /usr/local/bin/pget && echo "pget installed successfully!"
else
    echo "pget is already installed."
fi

# Download the model
pget "$MODEL" "$BASE_PATH/unet/$(basename "$MODEL")"
# Text encoders
pget "$CLIP" "$BASE_PATH/clip/$(basename "$CLIP")"
pget "$TEXT_ENC" "$BASE_PATH/clip/$(basename "$TEXT_ENC")"
# VAE
pget "$VAE" "$BASE_PATH/vae/$(basename "$VAE")"