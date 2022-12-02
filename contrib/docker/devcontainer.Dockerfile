# [ TODO ] mcr.microsoft.com/vscode/devcontainers/alpine
# https://github.com/microsoft/vscode-dev-containers/tree/master/containers/alpine/.devcontainer
FROM alpine
USER root

RUN apk upgrade --no-cache && \
  apk add --no-cache --progress git build-base findutils make bat exa \
  coreutils wget curl aria2 bash ncurses binutils jq sudo ripgrep g++ \
  vault fuse-dev libcap neofetch docker docker-compose openssh py3-pip yq && \
  setcap cap_ipc_lock= /usr/sbin/vault && \
  vault --version && \
  sed -i '/root/s/ash/bash/g' /etc/passwd

# Download Terraform
RUN git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv && \ 
  echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> /bin/envs && \
  ln -s ~/.tfenv/bin/* /usr/local/bin
RUN which tfenv && \
  tfenv install latest && \
  tfenv use latest

# Download kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl && \
  chmod +x ./kubectl && \
  sudo mv ./kubectl /usr/local/bin/kubectl && \
  kubectl version --client

# Downloading gcloud package
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

# Installing the package
RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh

# Adding the package path to local
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

RUN gcloud components install gke-gcloud-auth-plugin --quiet

WORKDIR /workspace
