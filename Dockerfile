ARG UBUNTU_VERSION=20.04
ARG PLATFORM="amd"
FROM --platform=linux/${PLATFORM}64 ubuntu:${UBUNTU_VERSION}

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        bash bash-completion ca-certificates lsb-release gnupg\
        wget curl apt-transport-https git \
        unzip rsync vim tmux less jq gettext xclip xsel python-is-python3

ARG PLATFORM="amd"
ARG TERRAFORM_VERSION=1.2.3
ARG HELM_VERSION=3.8.2

RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null \
    && echo "deb [arch=${PLATFORM}64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y azure-cli \
    && curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${PLATFORM}64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_${PLATFORM}64.zip -d /bin \
    && rm -f terraform_${TERRAFORM_VERSION}_linux_${PLATFORM}64.zip \
    && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/${PLATFORM}64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl \
    && curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-${PLATFORM}64.tar.gz -o helm.tar.gz \
    && tar xzvf helm.tar.gz && cd linux-${PLATFORM}64 \
    && chmod +x ./* \
    && mv ./helm /usr/local/bin/helm \
    && cd .. && rm -rf linux-${PLATFORM}64 && rm -f helm.tar.gz

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh \
    && mkdir -p ~/.ssh && chmod 700 ~/.ssh && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts \
    && git clone https://github.com/tinslice/dotfiles.git ~/.dotfiles \
    && rm -rf ~/.bashrc ~/.profile && cd ~/.dotfiles && ./install \
    && echo "source <(kubectl completion bash)" > ~/.bashrc_local_after

WORKDIR /workspace

ENTRYPOINT [ "/docker-entrypoint.sh" ]