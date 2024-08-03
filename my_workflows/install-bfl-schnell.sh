# The schnell model has better prompt-following, quality, and speed the RV5.1. 
# Ex prompt: full body professional portrait of a woman, age 27, blue eyes, white shoulder-length hair, with bangs, colombian chinese, wearing casual clothes

CLIP=https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors
TEXT_ENC=https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors
VAE=https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.sft
MODEL=https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/flux1-schnell.sft


# Download the model
wget -c $MODEL -P /workspace/ComfyUI/models/unet
# Text encoders
wget -c $CLIP -P /workspace/ComfyUI/models/clip/
wget -c $TEXT_ENC -P /workspace/ComfyUI/models/clip/
# VAE
wget -c $VAE -P /workspace/ComfyUI/models/vae/