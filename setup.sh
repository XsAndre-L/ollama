#!/bin/bash

make -j12 runners
make -j12 exe

#  docker build -t ollama .

# docker run --gpus all -p 11434:11434 -v "C:/Users/ahlou/.ollama:/root/.ollama" --name ollama ollama

# "C:/Users/ahlou/.ollama:/root/.ollama" is the path to the directory where the .ollama directory is located on the host machine. This directory contains the configuration files for the Ollama tool.
