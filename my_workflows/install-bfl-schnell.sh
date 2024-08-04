# The schnell model has better prompt-following, quality, and speed the RV5.1. 
# Ex prompt: full body professional portrait of a woman, age 27, blue eyes, white shoulder-length hair, with bangs, colombian chinese, wearing casual clothes

# Define a base path for model storage
BASE_PATH="/workspace/ComfyUI/models"

# Assets
CLIP=https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors
TEXT_ENC=https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors
VAE=https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.sft
MODEL=https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/flux1-schnell.sft

# VAE
wget "$VAE" -O "$BASE_PATH/vae/ae.safetensors"
# Text encoders
wget "$CLIP" -O "$BASE_PATH/clip/$(basename "$CLIP")"
wget "$TEXT_ENC" -O "$BASE_PATH/clip/$(basename "$TEXT_ENC")"
# Download the model
wget "$MODEL" -O "$BASE_PATH/unet/flux1-schnell.safetensors"