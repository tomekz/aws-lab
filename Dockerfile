# A simple Ubuntu container with Git and other common utilities installed.
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install terraform
RUN apt-get update && apt-get install -y gnupg software-properties-common curl
RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN gpg --no-default-keyring \
        --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
        --fingerprint
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list
RUN apt update && apt-get install terraform

# Install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" \
     && unzip awscliv2.zip \
     && ./aws/install

# Install ansible
RUN apt-get update && \
    add-apt-repository --yes ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3 python3-pip && \
    pip3 install ansible && \
    pip3 install boto3 --user

RUN useradd app --create-home
WORKDIR /home/app

USER app
