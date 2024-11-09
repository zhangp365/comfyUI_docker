# Introduction
This project dockerises the deployment of [comfyanonymous/ComfyUI](https://github.com/comfyanonymous/ComfyUI) and its variants. It provides a default configuration (corresponding to a vanilla deployment of the application)

*This goal of this project is to be to [comfyanonymous/ComfyUI](https://github.com/comfyanonymous/ComfyUI), what [AbdBarho/stable-diffusion-webui-docker](https://github.com/AbdBarho/stable-diffusion-webui-docker) is to [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui).*

# Update
For convenience in using the latest Comfy Docker, the Docker repository is updated daily. Simply use the latest version. The Docker image also includes the ControlNet and IPAdapter nodes for ComfyUI.

# Usage
*This project currently supports Linux as the deployment platform. It will also work using WSL2.*

## command
docker run --gpus all -t  -p 8188:8188 -e CLI_ARGS="" -v /your/path/outputs:/app/output -v /your/path/data:/data -d zhangp365/comfyui:latest

## docker hub address
https://hub.docker.com/repository/docker/zhangp365/comfyui/general 

## Pre-Requisites
- docker
- docker compose
- CUDA docker runtime

## Docker Compose
This is the recommended deployment method (it is the easiest and quickest way to manage folders and settings through updates and reinstalls). The recommend variant is `default` (it is an enhanced version of the vanilla application).


