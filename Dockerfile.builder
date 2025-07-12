FROM golang:1.24.4

# Disable interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV GOFLAGS="-buildvcs=false"

# Install cross-compilation dependencies
RUN set -x && \
    dpkg --add-architecture arm64 && \
    apt-get -qq update -y && \
    apt-get -qqqy -o Dpkg::Progress-Fancy="0" -o APT::Color="0" -o Dpkg::Use-Pty="0" install \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libwayland-dev \
    libwayland-egl1-mesa \
    libvulkan-dev \
    libx11-dev \
    libx11-xcb-dev \
    libxcb1-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxcursor-dev \
    libxi-dev \
    libxfixes-dev \
    libegl1-mesa-dev \
    libgl1-mesa-dev \
    libxkbcommon0 \
    libxkbcommon-x11-0 \
    libwayland-client0 \
    libwayland-cursor0 \
    libwayland-egl1 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcursor1 \
    libxfixes3 \
    libegl1-mesa \
    musl-dev \
    musl-tools \
    gcc-aarch64-linux-gnu \
    libc6-dev-arm64-cross \
    xvfb \
    imagemagick \
    fluxbox \
    tesseract-ocr \
    tesseract-ocr-eng \
    python3-pip \
    python3-venv \
    x11-utils \
    x11-xserver-utils \
    x11-apps \
    wmctrl \
    pkg-config \
    file \
    cabextract \
    chafa \
    libxkbcommon-dev:arm64 \
    libxkbcommon-x11-dev:arm64 \
    libwayland-dev:arm64 \
    libwayland-egl1-mesa:arm64 \
    libvulkan-dev:arm64 \
    libx11-dev:arm64 \
    libx11-xcb-dev:arm64 \
    libxcb1-dev:arm64 \
    libxrandr-dev:arm64 \
    libxinerama-dev:arm64 \
    libxcursor-dev:arm64 \
    libxi-dev:arm64 \
    libxfixes-dev:arm64 \
    libegl1-mesa-dev:arm64 \
    libgl1-mesa-dev:arm64 \
    libxkbcommon0:arm64 \
    libxkbcommon-x11-0:arm64 \
    libwayland-client0:arm64 \
    libwayland-cursor0:arm64 \
    libwayland-egl1:arm64 \
    libx11-6:arm64 \
    libx11-xcb1:arm64 \
    libxcb1:arm64 \
    libxcursor1:arm64 \
    libxfixes3:arm64 \
    libegl1-mesa:arm64 > /dev/null

# Install Wine from WineHQ repository (Debian Bookworm)
RUN set -x && \
    dpkg --add-architecture i386 && \
    mkdir -pm755 /etc/apt/keyrings && \
    echo 'deb http://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_12/ /' | tee /etc/apt/sources.list.d/Emulators:Wine:Debian.list && \
    curl -fsSL https://download.opensuse.org/repositories/Emulators:Wine:Debian/Debian_12/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/Emulators_Wine_Debian.gpg > /dev/null && \
    apt-get update && \
    apt-get -yqq install --fix-missing --install-recommends winehq-devel xvfb curl > /dev/null || { \
        echo "Fallback to WineHQ repository..." && \
        wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
        wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources && \
        apt-get -qq update -y && \
        apt-get install -yqq --fix-missing --install-recommends winehq-devel xvfb curl > /dev/null; \
    }

# Install winetricks
RUN curl -o /usr/local/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
    chmod +x /usr/local/bin/winetricks

# Initialize Wine and install corefonts
RUN export WINEARCH=win64 && \
    export WINEPREFIX=/tmp/wine-prefix && \
    export DISPLAY=:99 && \
    Xvfb :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset & \
    sleep 3 && \
    wine --version && \
    wineboot --init 2>/dev/null || true && \
    winetricks -q corefonts 2>/dev/null || echo "corefonts installation failed" && \
    pkill Xvfb || true

# Set up PKG_CONFIG_PATH for cross-compilation
ENV PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/aarch64-linux-gnu/pkgconfig:/usr/share/pkgconfig

# Verify installations
RUN wine --version && \
    winetricks --version && \
    chafa --version && \
    go version

WORKDIR /workspace 