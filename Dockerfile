# A simple Ubuntu container with Git and other common utilities installed.
FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt update && apt install -y \
  neovim  \
  tmux

RUN useradd app --create-home
WORKDIR /home/app

USER app
