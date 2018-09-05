FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y \
        jq \
        python \
        python-pip \ 
        curl \
        unzip \
        git \
    && rm -rf /var/lib/apt/lists/*

# install python and pip and aws cli
RUN set -xe && python -m pip install pip --upgrade \
            && python -m pip install awscli --upgrade

# install terraform
RUN curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip
RUN unzip /tmp/terraform.zip -d /usr/local/bin; /bin/rm /tmp/terraform.zip

RUN useradd -m -s /bin/bash ubuntu
WORKDIR /home/ubuntu
USER ubuntu

# install and set up gen3
RUN git clone https://github.com/uc-cdis/cloud-automation.git \
    && echo "export GEN3_HOME=~/cloud-automation" >> ~/.bashrc \
    && echo 'source "${GEN3_HOME}/gen3/gen3setup.sh"' >> ~/.bashrc 

CMD /bin/bash

