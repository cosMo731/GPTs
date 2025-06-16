FROM docker:24

ENV TERRAFORM_VERSION=1.8.5 \
    TRIVY_VERSION=0.51.1 \
    GITLEAKS_VERSION=8.18.1

# Install dependencies
RUN apk add --no-cache \
        bash \
        curl \
        git \
        jq \
        python3 \
        py3-pip \
        unzip

# Install AWS CLI
RUN pip3 install --no-cache-dir awscli

# Install Terraform
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform.zip

# Install trivy
RUN curl -fsSL https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz | tar zx -C /usr/local/bin trivy

# Install gitleaks
RUN curl -fsSL https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz | tar zx -C /usr/local/bin gitleaks

ENTRYPOINT ["/bin/sh"]
