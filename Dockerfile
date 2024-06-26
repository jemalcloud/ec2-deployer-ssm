# Use a specific version of Alpine Linux as the base image
ARG ALPINE_VERSION=3.18
FROM alpine:${ALPINE_VERSION}

# Set environment variables
ARG TERRAFORM_VERSION="1.6.5"
ARG ANSIBLE_VERSION="2.15.0"
ARG PACKER_VERSION="1.9.4"

LABEL maintainer="cloudsheger <cloudsheger@gmail.com>"
LABEL terraform_version=${TERRAFORM_VERSION}
LABEL ansible_version=${ANSIBLE_VERSION}
LABEL packer_version=${PACKER_VERSION}

ENV TERRAFORM_VERSION=${TERRAFORM_VERSION}
ENV PACKER_VERSION=${PACKER_VERSION}

# Install required dependencies and tools
RUN apk --no-cache add \
    ansible \
    aws-cli \
    curl \
    git \
    python3 \
    py3-pip \
    unzip \
    gcc \
    libffi-dev \
    musl-dev \
    openssl-dev \
    make # <-- Added make here

# Create and activate a virtual environment
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Upgrade pip within the virtual environment
RUN pip install --upgrade pip setuptools wheel

# Install other tools and dependencies
# Uncomment the line below if a specific version of awscli is required
# RUN pip install --upgrade awscli==${AWSCLI_VERSION}

# Download and install Terraform and Packer
RUN curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && curl -LO https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
    && unzip '*.zip' -d /usr/local/bin \
    && rm *.zip

# Create a non-root user with a home directory and add it to the wheel group
RUN addgroup -S jenkins && adduser -S -G jenkins -G wheel jenkins

# Create a working directory and give ownership to the jenkins user
RUN mkdir -p /home/jenkins \
    && chown -R jenkins:jenkins /home/jenkins

# Set the working directory
WORKDIR /home/jenkins

# Switch to the non-root user
USER jenkins

# Define the default command to run when the container starts
CMD ["/bin/sh"]
