# Base image with CUDA support for Windows
FROM nvidia/cuda:11.3.1-cudnn8-runtime-ubuntu20.04 AS builder

# Build arguments
ARG GOLANG_VERSION=1.22.8
ARG CUDA_VERSION_11=11.3.1
ARG CUDA_VERSION_12=12.4.0
ARG OLLAMA_SKIP_CUDA_GENERATE=0
ARG OLLAMA_SKIP_ROCM_GENERATE=1
ARG OLLAMA_FAST_BUILD=1
ARG VERSION=1.0.0

# Install dependencies
RUN apt-get update && \
  apt-get install -y \
  git \
  curl \
  build-essential \
  ca-certificates \
  zsh \
  ccache \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Go
RUN curl -s -L https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz | tar xz -C /usr/local && \
  ln -s /usr/local/go/bin/go /usr/local/bin/go && \
  ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

# Set up environment variables
ENV PATH /usr/local/cuda/bin:$PATH
ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:$LD_LIBRARY_PATH
ENV CGO_ENABLED 1
ENV GOARCH amd64

# Set working directory
WORKDIR /go/src/github.com/ollama/ollama/

# Copy Ollama source code
COPY . .

# Build Ollama
RUN --mount=type=cache,target=/root/.ccache \
  # if grep "^flags" /proc/cpuinfo | grep avx > /dev/null; then \
  # make -j $(nproc) dist ; \
  # else \
  make -j $(nproc) dist ; 
# fi

# Create a runtime image
FROM nvidia/cuda:11.3.1-cudnn8-runtime-ubuntu20.04 AS runtime

# Install runtime dependencies
RUN apt-get update && \
  apt-get install -y ca-certificates && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy Ollama binaries and libraries
COPY --from=builder /go/src/github.com/ollama/ollama/dist/linux-amd64/bin/ /bin/
COPY --from=builder /go/src/github.com/ollama/ollama/dist/linux-amd64/lib/ /lib/


EXPOSE 11434
ENV OLLAMA_HOST 0.0.0.0

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]