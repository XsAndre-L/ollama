### Available at "http://localhost:11434/"

`bash ./scripts/build.sh 0.5.4`

first run the llama server "ollama serve"

then `ollama run llama3.3`

bash ./scripts/build.sh 0.5.4

### models available in:

/home/ahlou/.ollama/models/blobs

# Docker

## BUILD:

`docker build --build-arg TARGETARCH=amd64 --build-arg OLLAMA_SKIP_ROCM_GENERATE=1 -t ollama:local .`

### GPU Enabled

`podman build --build-arg TARGETARCH=amd64 --build-arg OLLAMA_FAST_BUILD=0 --build-arg VERSION=latest --build-arg OLLAMA_SKIP_ROCM_GENERATE=1 --build-arg OLLAMA_SKIP_CUDA_GENERATE=0 -t ollama:gpu-enabled .`

## RUN:

`podman run --name ollama --rm -it -p 11434:11434 ollama:local`
`podman run --name ollama --rm -it -p 11434:11434 ollama:gpu-enabled`

`podman run --name ollama --rm -it --device /dev/nvidia0 --device /dev/nvidiactl --device /dev/nvidia-uvm --device /dev/nvidia-uvm-tools -v /usr/bin/nvidia-smi:/usr/bin/nvidia-smi:ro -v /usr/lib/x86_64-linux-gnu/libcuda.so:/usr/lib/x86_64-linux-gnu/libcuda.so:ro -v /usr/lib/x86_64-linux-gnu/libnvidia-ml.so:/usr/lib/x86_64-linux-gnu/libnvidia-ml.so:ro   ollama:gpu-enabled`

`podman run --name ollama --rm -it --device /dev/nvidia0 -d -p 11434:11434 -v /home/ahlou/.ollama/models:/root/.ollama/models --device /dev/nvidiactl --device /dev/nvidia-uvm --device /dev/nvidia-uvm-tools -v /usr/bin/nvidia-smi:/usr/bin/nvidia-smi:ro -v /usr/lib/x86_64-linux-gnu/libcuda.so:/usr/lib/x86_64-linux-gnu/libcuda.so:ro -v /usr/lib/x86_64-linux-gnu/libnvidia-ml.so:/usr/lib/x86_64-linux-gnu/libnvidia-ml.so:ro ollama:gpu-enabled`

`podman run --name ollama --rm -it --device /dev/nvidia0 -d -p 11434:11434 -v /home/ahlou/.ollama/models:/root/.ollama/models --device /dev/nvidiactl --device /dev/nvidia-uvm --device /dev/nvidia-uvm-tools -v /usr/bin/nvidia-smi:/usr/bin/nvidia-smi:ro -v /usr/lib/x86_64-linux-gnu/libcuda.so:/usr/lib/x86_64-linux-gnu/libcuda.so:ro -v /usr/lib/x86_64-linux-gnu/libnvidia-ml.so:/usr/lib/x86_64-linux-gnu/libnvidia-ml.so:ro ollama:gpu-enabled /usr/local/lib/ollama/runners/cuda_v12_avx/ollama_llama_server runner --n-gpu-layers -1`

`podman run --name ollama --rm -it --gpus all --device /dev/nvidia0 -d -p 11434:11434 -v /home/ahlou/.ollama/models:/root/.ollama/models --device /dev/nvidiactl --device /dev/nvidia-uvm --device /dev/nvidia-uvm-tools -v /usr/bin/nvidia-smi:/usr/bin/nvidia-smi:ro -v /usr/lib/x86_64-linux-gnu/libcuda.so:/usr/lib/x86_64-linux-gnu/libcuda.so:ro -v /usr/lib/x86_64-linux-gnu/libnvidia-ml.so:/usr/lib/x86_64-linux-gnu/libnvidia-ml.so:ro --entrypoint /usr/local/lib/ollama/runners/cuda_v12_avx/ollama_llama_server ollama:gpu-enabled runner --n-gpu-layers 40`

<!-- #### NEWWW

`podman run -d -p 11434:11434 -v /home/ahlou/.ollama/models --name ollama --rm ollama:local`
`podman run -d -p 11434:11434 -v /home/ahlou/.ollama/models:/root/.ollama/models --gpus=all --name ollama-gpu --rm ollama:gpu-enabled` -->

# GPU Drivers:

### step 1:

ubuntu-drivers devices

### step 2:

sudo apt-get install -y nvidia-driver-560

https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=24.04&target_type=deb_local

sudo apt-get install -y nvidia-open

https://developer.nvidia.com/cudnn-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=24.04&target_type=deb_local

sudo apt-get -y install cudnn-cuda-12

watch -n 1 nvidia-smi


### last steps i took on running ollama container

podman exec -it ollama ls /root/.ollama/models/manifests/registry.ollama.ai/library
