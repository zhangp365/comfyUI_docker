FROM pytorch/pytorch:2.2.2-cuda11.8-cudnn8-runtime AS env_base
ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN --mount=type=cache,target=/var/cache/apt \
apt-get update && apt-get install -y git vim libgl1-mesa-glx libglib2.0-0 python3-dev gcc g++ && apt-get clean
RUN pip3 install --no-cache-dir --upgrade pip setuptools


FROM env_base AS base 
# Clone comfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI /app

# Install comfyUI
RUN --mount=type=cache,target=/root/.cache/pip pip3  install --no-cache-dir -r /app/requirements.txt
RUN pip install --no-cache-dir bitsandbytes==0.41.1 torchsde onnxruntime-gpu ninja triton opencv-python spandrel kornia
RUN pip install --no-cache-dir -v xformers==0.0.26 --index-url https://download.pytorch.org/whl/cu118

RUN cd /app/custom_nodes && git clone https://github.com/ltdrdata/ComfyUI-Manager.git
RUN cd /app/custom_nodes && git clone https://github.com/twri/sdxl_prompt_styler.git
RUN cd /app/custom_nodes && git clone  https://github.com/Fannovel16/comfyui_controlnet_aux && cd comfyui_controlnet_aux && pip install --no-cache-dir -r requirements.txt
RUN cd /app/custom_nodes && git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git 
RUN cd /app/custom_nodes && git clone https://github.com/zhangp365/ComfyUI-utils-nodes.git && pip install --no-cache-dir google-generativeai

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1
ENV LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"
ENV ROOT=/app

FROM base as base_ready
RUN rm -rf /root/.cache/pip/*
# Finalise app setup
WORKDIR ${ROOT}
EXPOSE 8188
# Required for Python print statements to appear in logs
ENV PYTHONUNBUFFERED=1
# Force variant layers to sync cache by setting --build-arg BUILD_DATE
ARG BUILD_DATE
ENV BUILD_DATE=$BUILD_DATE
RUN echo "$BUILD_DATE" > /build_date.txt

# Copy and enable all scripts
COPY ./scripts /scripts
RUN chmod +x /scripts/*
RUN cd /app && git checkout . && git pull
RUN cd /app/custom_nodes/comfyui_controlnet_aux && git pull
RUN cd /app/custom_nodes/ComfyUI_IPAdapter_plus && git pull
RUN ln -s /opt/conda/lib/libnvrtc.so.11.8.89 /opt/conda/lib/python3.10/site-packages/torch/lib/libnvrtc.so
RUN sed -i 's/if int((xformers\.__version__).split(".")\[2\]) >= 28:/if int((xformers.__version__).split(".")\[2\].split("+"\)\[0\]) >= 28:/g' /app/comfy/ldm/pixart/blocks.py
# Run
ENTRYPOINT ["/scripts/docker-entrypoint.sh"]

FROM base_ready AS default
RUN echo "DEFAULT" >> /variant.txt
ENV CLI_ARGS=""
CMD python3 /app/main.py --listen 0.0.0.0 ${CLI_ARGS} 