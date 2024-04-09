# A simple Ubuntu container with Git and other common utilities installed.
FROM --platform=linux/amd64 mcr.microsoft.com/devcontainers/base:ubuntu

ENV TERM=xterm-256color

# Install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
     && unzip awscliv2.zip \
     && ./aws/install

# Install ansible
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-boto3 && \
    pip3 install ansible && \
    pip3 install boto


RUN useradd app --create-home
WORKDIR /home/app

# Install tfenv
RUN git clone https://github.com/tfutils/tfenv.git tfenv
ENV PATH="/home/app/tfenv/bin:${PATH}"

# Install go
RUN wget https://go.dev/dl/go1.20.3.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go1.20.3.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"

# install eksctl
RUN curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_arm64.tar.gz" && \
    tar -xzf eksctl_Linux_arm64.tar.gz -C /tmp && rm eksctl_Linux_arm64.tar.gz && \
    sudo mv /tmp/eksctl /usr/local/bin

# install kubectl
RUN sudo apt-get update && \
    sudo apt-get install -y apt-transport-https ca-certificates curl && \
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
    sudo apt-get update && \
    sudo apt-get install -y kubectl

# install AWS session manager plugin
RUN curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
    sudo dpkg -i session-manager-plugin.deb

RUN mkdir /home/app/scans && chmod 777 /home/app/scans

USER app
