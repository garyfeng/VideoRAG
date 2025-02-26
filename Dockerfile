# Use an official lightweight Python image
FROM python:3.9-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# Install system dependencies, including build tools for hnswlib
RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    wget \
    unzip \
    libgl1-mesa-glx \
    libglib2.0-0 \
    bash \
    build-essential \
    cmake \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -u 1000 user
USER user
WORKDIR /home/user

# Clone the VideoRAG repository
RUN git clone https://github.com/garyfeng/VideoRAG.git
WORKDIR /home/user/VideoRAG

# Install Python dependencies without GPU support
RUN pip install --no-cache-dir \
    numpy==1.26.4 \
    torch==2.1.0 \
    torchvision==0.16.0 \
    torchaudio==2.1.0 \
    accelerate==0.30.1 \
    bitsandbytes==0.43.1 \
    moviepy==1.0.3 \
    git+https://github.com/facebookresearch/pytorchvideo.git@28fe037d212663c6a24f373b94cc5d478c8c1a1d \
    timm \
    ftfy \
    regex \
    einops \
    fvcore \
    eva-decord==0.6.1 \
    iopath \
    matplotlib \
    types-regex \
    cartopy \
    ctranslate2==4.4.0 \
    faster_whisper==1.0.3 \
    neo4j \
    hnswlib \
    xxhash \
    nano-vectordb \
    transformers==4.37.1 \
    tiktoken \
    openai \
    tenacity

# Install ImageBind
RUN cd ImageBind && pip install .

# Install curl and git-lfs only when needed
# Temporarily switch to root for curl and git-lfs installation
USER root
RUN apt-get update && apt-get install -y curl && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y git-lfs && \
    git lfs install && \
    apt-get remove -y curl && apt-get autoremove -y && apt-get clean

# Switch back to non-root user
USER user


# Download necessary checkpoints
RUN git lfs install && \
    git lfs clone https://huggingface.co/openbmb/MiniCPM-V-2_6-int4 && \
    git lfs clone https://huggingface.co/Systran/faster-distil-whisper-large-v3 && \
    mkdir .checkpoints && \
    cd .checkpoints && \
    wget https://dl.fbaipublicfiles.com/imagebind/imagebind_huge.pth

# Set the working directory
WORKDIR /home/user/VideoRAG

# Set entry point as bash
ENTRYPOINT ["/bin/bash"]
