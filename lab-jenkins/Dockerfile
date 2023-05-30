# A simple Ubuntu container with Git and other common utilities installed.
FROM --platform=linux/amd64 mcr.microsoft.com/devcontainers/base:ubuntu

ENV TERM=xterm-256color

# Install terraform
RUN apt-get update && apt-get install -y gnupg software-properties-common curl

RUN yes | unminimize

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
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
     && unzip awscliv2.zip \
     && ./aws/install

# Install ansible
RUN apt-get update && \
    add-apt-repository --yes ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3 python3-pip python3-boto3 && \
    pip3 install ansible && \
    pip3 install boto

# Install go
WORKDIR /tmp 
RUN wget https://go.dev/dl/go1.20.3.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go1.20.3.linux-amd64.tar.gz && \
    echo "export PATH=$PATH:/usr/local/go/bin:/home/app/go/bin" >> ~/.bashrc

RUN useradd app --create-home
WORKDIR /home/app

USER app
