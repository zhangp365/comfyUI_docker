FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime AS env_base
RUN apt-get update && apt-get install -y   git vim && apt-get clean
# Instantiate venv and pre-activate
RUN pip3 install --no-cache-dir --upgrade pip setuptools


FROM env_base AS base 
# Clone comfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI /app

# Install comfyUI
COPY requirements.txt /app/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip pip3  install --no-cache-dir -r /app/requirements.txt
RUN pip install --no-cache-dir bitsandbytes==0.41.1

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
RUN cd /app && git pull

# Run
ENTRYPOINT ["/scripts/docker-entrypoint.sh"]

FROM base_ready AS default
RUN echo "DEFAULT" >> /variant.txt
ENV CLI_ARGS=""
CMD python3 /app/main.py ${CLI_ARGS}