#!/bin/bash

PACKAGES=(
    "python3-pip"
    "pylint"
    "ansible-lint"
    "ansible"
    "pre-commit"
    "black"
    "coreutils"
    "gawk"
    "gnupg"
    "software-properties-common"
)

# Check if the system is Debian-based
if [ -x "$(command -v apt)" ]; then
  echo "Debian-based system detected"
  export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
  apt update -y

  # tflint
  curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

  # tfsec
  curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

  # hadolint
  sudo wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64
  sudo chmod +x /bin/hadolint

  # terraform-docs
  sudo snap install terraform-docs

  # terraform
  wget -O- https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
  # add repo
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update -y
  sudo apt install terraform

  for pkg in "${PACKAGES[@]}"; do
    apt install "${pkg}" -y
  done

  pip3 install checkov

  pip3 install pre-commit
  pre-commit --version
  type pre-commit

  curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

elif [ -x "$(command -v yum)" ]; then
  echo "RPM-based system detected."
  yum update -y
  yum install -y pre-commit

else
  echo "System unsupported, update this script"
  exit 1
fi

/usr/bin/pre-commit run -a
