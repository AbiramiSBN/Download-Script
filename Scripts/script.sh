#!/usr/bin/env bash
# Ubuntu full dev workstation bootstrap (zero-arg, batteries-included)
# Includes: base/CLI, C/C++, Python, Rust, Node, Go, Java, .NET, Docker/Podman, K8s toolchain,
# DevOps (Terraform/Packer/OpenTofu/k6/GH CLI), Cloud CLIs (AWS/Azure/GCloud),
# Databases tools (psql/sqlite/redis/mongosh/DBeaver),
# Browsers/GUI apps, Warp Terminal, AI stack, and Qt (C++ & Python).
# Safe to re-run. WSL-aware (skips snaps/GPU drivers as needed). Uses official repos where possible.

set -Eeuo pipefail

### ------------ helpers ------------
log() { printf "\033[1;36m[INFO]\033[0m %s\n" "$*"; }
warn(){ printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*" >&2; }
die() { err "$*"; exit 1; }

require_sudo() {
  if ! sudo -v; then die "Need sudo privileges."; fi
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

is_wsl()     { grep -qiE "microsoft|wsl" /proc/version 2>/dev/null; }
has_snap()   { command -v snap >/dev/null 2>&1; }
codename()   { . /etc/os-release; echo "$VERSION_CODENAME"; }
arch()       { dpkg --print-architecture; }
cpu_arch()   { case "$(uname -m)" in x86_64|amd64) echo amd64;; aarch64|arm64) echo arm64;; *) uname -m;; esac; }
has_nvidia() { lspci 2>/dev/null | grep -qi nvidia || lsmod | grep -qi nvidia; }
has_amd()    { lspci 2>/dev/null | grep -qiE 'AMD|ATI'; }

apt_install() { sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"; }
add_keyring() { curl -fsSL "$1" | sudo gpg --dearmor -o "/usr/share/keyrings/$2"; }

### ------------ start ------------
require_sudo
CODENAME="$(codename)"
ARCH="$(arch)"
CPUARCH="$(cpu_arch)"

log "Updating APT and installing core prerequisites..."
sudo apt-get update -y
apt_install ca-certificates curl wget gnupg lsb-release apt-transport-https software-properties-common dirmngr unzip zip tar \
            build-essential pkg-config

sudo apt-get -f install -y || true

### ------------ official repos ------------
log "Adding VS Code repo..."
add_keyring https://packages.microsoft.com/keys/microsoft.asc microsoft.gpg
echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
  | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null

log "Adding Google Chrome repo..."
add_keyring https://dl.google.com/linux/linux_signing_key.pub google.gpg
echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
  | sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null

log "Adding Docker repo..."
add_keyring https://download.docker.com/linux/ubuntu/gpg docker.gpg
echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

log "Adding Microsoft packages repo..."
echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/${CODENAME}/prod ${CODENAME} main" \
  | sudo tee /etc/apt/sources.list.d/microsoft-prod.list >/dev/null

log "Adding HashiCorp repo..."
add_keyring https://apt.releases.hashicorp.com/gpg hashicorp.gpg
echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com ${CODENAME} main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null

log "Adding Kubernetes repo..."
add_keyring https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key kubernetes-1-30.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-1-30.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null

log "Adding Google Cloud SDK repo..."
add_keyring https://packages.cloud.google.com/apt/doc/apt-key.gpg google-cloud.gpg
echo "deb [signed-by=/usr/share/keyrings/google-cloud.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
  | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list >/dev/null

log "Adding DBeaver CE repo..."
add_keyring https://dbeaver.io/debs/dbeaver.gpg dbeaver.gpg
echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/dbeaver.gpg] https://dbeaver.io/debs/dbeaver-ce /" \
  | sudo tee /etc/apt/sources.list.d/dbeaver.list >/dev/null

log "Adding k6 (Grafana) repo..."
add_keyring https://dl.k6.io/key.gpg k6.gpg
echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/k6.gpg] https://dl.k6.io/deb stable main" \
  | sudo tee /etc/apt/sources.list.d/k6.list >/dev/null

sudo apt-get update -y

### ------------ base & CLI ------------
log "Installing base utilities & enhanced CLI..."
apt_install git git-lfs gnupg2 htop tree net-tools openssh-client screen tmux neovim nano vim jq yq dos2unix parallel \
            zstd lz4 aria2 httpie nmap iperf3 dnsutils direnv \
            ripgrep fd-find fzf bat eza \
            shellcheck yamllint \
            gcc g++ make cmake ninja-build pkg-config \
            software-properties-common

[ -x /usr/bin/fdfind ] && sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd || true
[ -x /usr/bin/batcat ] && sudo ln -sf /usr/bin/batcat /usr/local/bin/bat || true

if ! command -v starship >/dev/null 2>&1; then
  sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y
  grep -q 'starship init' "$HOME/.bashrc" 2>/dev/null || echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
fi

### ------------ fonts ------------
log "Installing fonts..."
apt_install fonts-liberation fonts-dejavu fonts-noto fonts-noto-cjk fonts-noto-color-emoji
tmpf="$(mktemp -d)"; pushd "$tmpf" >/dev/null
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip || true
unzip -o JetBrainsMono.zip -d JetBrainsMono || true
mkdir -p "$HOME/.local/share/fonts"; cp -f JetBrainsMono/*.ttf "$HOME/.local/share/fonts/" || true
fc-cache -fv || true
popd >/dev/null; rm -rf "$tmpf"

### ------------ C/C++ stack ------------
log "Installing C/C++ stack..."
apt_install clang clangd llvm lldb gdb valgrind ccache mold libc++-dev libc++abi-dev cppcheck bear

### ------------ Python stack ------------
log "Installing Python stack..."
apt_install python3 python3-venv python3-pip python3-dev python3-full
python3 -m pip install --upgrade --user pip pipx
~/.local/bin/pipx ensurepath || true
python3 -m pipx install uv || true
python3 -m pipx install poetry || true
python3 -m pipx install pre-commit ruff black || true
python3 -m pipx install locust || true
python3 -m pipx install pgcli || true

### ------------ Qt stack (C++ & Python) ------------
log "Installing Qt (Qt6 + Qt5 compatibility) for C++ and Python..."

apt_install qt6-base-dev qt6-base-dev-tools qt6-declarative-dev \
            qt6-tools-dev qt6-tools-dev-tools \
            qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-templates || true

apt_install qtbase5-dev qtbase5-dev-tools qtchooser qt5-qmake qtdeclarative5-dev \
            qttools5-dev qttools5-dev-tools \
            qml-module-qtquick-controls qml-module-qtgraphicaleffects || true

apt_install qtcreator || true

QTENV="$HOME/.venvs/qt"
python3 -m venv "$QTENV" || true
. "$QTENV/bin/activate"
pip install --upgrade pip wheel setuptools
pip install --upgrade pyside6 pyside6-addons shiboken6
pip install --upgrade pyqt6 pyqt6-qt6 pyqt6-sip pyqt6-tools || true
pip install --upgrade qtpy qtawesome qt-material
pip install --upgrade ipykernel && python -m ipykernel install --user --name=qt-env --display-name="Python (Qt)"
deactivate || true

### ------------ Rust stack ------------
log "Installing Rust (rustup + common tools)..."
if ! command -v rustup >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.bashrc"
fi
source "$HOME/.cargo/env" || true
rustup update stable
rustup component add rustfmt clippy rust-analyzer || true
cargo install --locked cargo-edit cargo-watch just || true

### ------------ Node.js ------------
log "Installing Node.js (nvm + LTS + CLIs)..."
if [ ! -d "$HOME/.nvm" ]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'
npm -g install yarn pnpm eslint prettier typescript ts-node @biomejs/biome @neondatabase/cli

if [ "$(cpu_arch)" = "amd64" ]; then
  log "Installing PlanetScale CLI..."
  tmpd="$(mktemp -d)"; pushd "$tmpd" >/dev/null
  curl -fsSLO "https://github.com/planetscale/cli/releases/latest/download/pscale_amd64.tar.gz" || true
  tar -xzf "pscale_amd64.tar.gz" || true
  sudo mv pscale /usr/local/bin/pscale 2>/dev/null || true
  popd >/dev/null; rm -rf "$tmpd"
fi

### ------------ Go / Java / .NET ------------
log "Installing Go, Java 21, .NET 8..."
apt_install golang
apt_install openjdk-21-jdk maven gradle
apt_install dotnet-sdk-8.0

### ------------ Docker & Podman ------------
log "Installing Docker Engine + Compose + Buildx..."
apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || {
  apt_install ca-certificates curl gnupg
  sudo apt-get update -y
  apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}
sudo usermod -aG docker "$USER" || true

log "Installing Podman + tooling..."
apt_install podman uidmap slirp4netns
apt_install podman-docker || true
python3 -m pipx install podman-compose || true

### ------------ Kubernetes toolchain ------------
log "Installing Kubernetes tools (kubectl, helm, kind, k9s, stern, tilt, minikube)..."
apt_install kubectl
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl -fsSL "https://github.com/kubernetes-sigs/kind/releases/download/v0.23.0/kind-linux-amd64" -o /tmp/kind && chmod +x /tmp/kind && sudo mv /tmp/kind /usr/local/bin/kind
K9S_VER="v0.32.5"
curl -fsSL "https://github.com/derailed/k9s/releases/download/${K9S_VER}/k9s_Linux_amd64.tar.gz" -o /tmp/k9s.tgz
sudo tar -xzf /tmp/k9s.tgz -C /usr/local/bin k9s && rm -f /tmp/k9s.tgz
STERN_VER="v1.30.0"
curl -fsSL "https://github.com/stern/stern/releases/download/${STERN_VER}/stern_${STERN_VER#v}_linux_amd64.tar.gz" -o /tmp/stern.tgz
sudo tar -xzf /tmp/stern.tgz -C /usr/local/bin stern && rm -f /tmp/stern.tgz
curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash
curl -fsSL "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-$(cpu_arch)" -o /tmp/minikube
chmod +x /tmp/minikube && sudo mv /tmp/minikube /usr/local/bin/minikube

### ------------ DevOps tools ------------
log "Installing DevOps tools..."
apt_install terraform packer k6
if ! command -v gh >/dev/null 2>&1; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update -y && apt_install gh
fi
if ! command -v tofu >/dev/null 2>&1; then
  log "Installing OpenTofu..."
  TOFU_URL="https://github.com/opentofu/opentofu/releases/latest/download/tofu_$(cpu_arch).tar.gz"
  tmpd="$(mktemp -d)"; pushd "$tmpd" >/dev/null
  curl -fsSLo tofu.tgz "${TOFU_URL}" && tar -xzf tofu.tgz
  sudo mv tofu /usr/local/bin/tofu 2>/dev/null || true
  popd >/dev/null; rm -rf "$tmpd"
fi
curl -fsSL -o /tmp/hadolint "https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-$(uname -m)"
chmod +x /tmp/hadolint && sudo mv /tmp/hadolint /usr/local/bin/hadolint
SHFMT_VER="v3.8.0"
curl -fsSL -o /tmp/shfmt "https://github.com/mvdan/sh/releases/download/${SHFMT_VER}/shfmt_${SHFMT_VER}_linux_amd64"
chmod +x /tmp/shfmt && sudo mv /tmp/shfmt /usr/local/bin/shfmt

### ------------ Cloud CLIs ------------
log "Installing cloud CLIs (AWS, Azure, GCloud)..."
if ! command -v aws >/dev/null 2>&1; then
  tmpd="$(mktemp -d)"; pushd "$tmpd" >/dev/null
  curl -fsSLO "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
  unzip -q awscli-exe-linux-x86_64.zip
  sudo ./aws/install --update
  popd >/dev/null; rm -rf "$tmpd"
fi
apt_install azure-cli
apt_install google-cloud-cli

### ------------ Databases & tools ------------
log "Installing DB clients & GUI..."
apt_install postgresql-client sqlite3 redis-tools
if ! grep -q "mongodb-org" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
  add_keyring https://pgp.mongodb.com/server-7.0.asc mongodb.gpg
  echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/mongodb.gpg] https://repo.mongodb.org/apt/ubuntu ${CODENAME}/mongodb-org/7.0 multiverse" \
    | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list >/dev/null
  sudo apt-get update -y || true
fi
apt_install mongodb-mongosh || true
apt_install dbeaver-ce

### ------------ Browsers & Desktop apps ------------
log "Installing browsers & desktop apps..."
apt_install google-chrome-stable code vlc gimp inkscape obs-studio

log "Installing Warp Terminal..."
tmpw="$(mktemp -d)"; pushd "$tmpw" >/dev/null
curl -fL "https://app.warp.dev/download?package=deb" -o warp-terminal.deb
sudo dpkg -i warp-terminal.deb || sudo apt-get -f install -y
popd >/dev/null; rm -rf "$tmpw"

tmpd2="$(mktemp -d)"; pushd "$tmpd2" >/dev/null
aria2c -x8 -s8 -o slack.deb https://downloads.slack-edge.com/desktop-releases/linux/x64/4.39.95/slack-desktop-4.39.95-amd64.deb || true
aria2c -x8 -s8 -o discord.deb "https://discord.com/api/download?platform=linux&format=deb" || true
sudo dpkg -i slack.deb discord.deb || sudo apt-get -f install -y || true
popd >/dev/null; rm -rf "$tmpd2"

if ! is_wsl && has_snap; then
  log "Installing Snap apps..."
  sudo snap install firefox || warn "Firefox snap failed."
  sudo snap install spotify || true
  sudo snap install telegram-desktop || true
  sudo snap install postman || true
fi

### ------------ AI / GPU stack ------------
log "Setting up Python AI stack..."
AIENV="$HOME/.venvs/ai"
python3 -m venv "$AIENV" || true
. "$AIENV/bin/activate"
pip install --upgrade pip wheel setuptools
pip install --upgrade numpy scipy pandas scikit-learn jupyterlab ipykernel matplotlib
pip install --upgrade onnx onnxruntime onnxruntime-tools
pip install --upgrade tensorflow-cpu || true
pip install --upgrade openvino-dev || true
pip install --upgrade torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
deactivate || true

if has_nvidia && ! is_wsl; then
  log "NVIDIA GPU detected — attempting CUDA toolkit & GPU wheels..."
  add_keyring https://developer.download.nvidia.com/compute/cuda/repos/ubuntu${CODENAME/./}/x86_64/3bf863cc.pub nvidia-cuda.gpg || true
  echo "deb [signed-by=/usr/share/keyrings/nvidia-cuda.gpg] https://developer.download.nvidia.com/compute/cuda/repos/ubuntu${CODENAME/./}/x86_64/ /" \
    | sudo tee /etc/apt/sources.list.d/cuda.list >/dev/null || true
  sudo apt-get update -y || true
  apt_install cuda-toolkit-12-5 || true
  . "$AIENV/bin/activate"
  pip install --upgrade torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124 || true
  pip install --upgrade onnxruntime-gpu || true
  deactivate || true
fi

### ------------ cleanup ------------
log "Finalizing..."
sudo apt-get -f install -y || true
sudo apt-get autoremove -y
sudo apt-get clean

log "✅ All components installed."
log "• Open a new terminal to pick up PATH changes (starship, rustup, nvm)."
log "• Log out/in (or reboot) to use Docker without sudo."
log "• Python Qt venv: source ~/.venvs/qt/bin/activate"
log "• AI venv:        source ~/.venvs/ai/bin/activate"
