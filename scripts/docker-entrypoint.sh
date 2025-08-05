#!/bin/bash

declare -A MOUNTS
# main
MOUNTS["${ROOT}/models/checkpoints"]="/data/checkpoints"
MOUNTS["${ROOT}/models/clip"]="/data/clip"
MOUNTS["${ROOT}/models/clip_vision"]="/data/clip_vision"
MOUNTS["${ROOT}/models/configs"]="/data/configs"
MOUNTS["${ROOT}/models/controlnet"]="/data/controlnet"
MOUNTS["${ROOT}/models/diffusers"]="/data/diffusers"
MOUNTS["${ROOT}/models/embeddings"]="/data/embeddings"
MOUNTS["${ROOT}/models/gligen"]="/data/gligen"
MOUNTS["${ROOT}/models/hypernetworks"]="/data/hypernetworks"
MOUNTS["${ROOT}/models/loras"]="/data/loras"
MOUNTS["${ROOT}/models/style_models"]="/data/style_models"
MOUNTS["${ROOT}/models/unet"]="/data/unet"
MOUNTS["${ROOT}/models/upscale_models"]="/data/upscale_models"
MOUNTS["${ROOT}/models/vae"]="/data/vae"
MOUNTS["${ROOT}/models/vae_approx"]="/data/vae_approx"
MOUNTS["${ROOT}/models/diffusion_models"]="/data/diffusion_models"
MOUNTS["${ROOT}/models/photomaker"]="/data/photomaker"
MOUNTS["${ROOT}/models/text_encoders"]="/data/text_encoders"

for to_path in "${!MOUNTS[@]}"; do
  set -Eeuo pipefail
  from_path="${MOUNTS[${to_path}]}"
  rm -rf "${to_path}"
  if [ ! -f "$from_path" ]; then
    mkdir -vp "$from_path"
  fi
  mkdir -vp "$(dirname "${to_path}")"
  ln -sT "${from_path}" "${to_path}"
  echo Mounted $(basename "${from_path}")
done

# Print build date
BUILD_DATE=$(cat /build_date.txt)
echo "=== Image build date: $BUILD_DATE ===" 

exec "$@"
