# .devcontainer/Dockerfile
# JUCE 8.0.10 Development Container for Linux builds
FROM mcr.microsoft.com/devcontainers/cpp:1-debian-12

# Install JUCE dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
    # Audio/MIDI
    libasound2-dev \
    libjack-jackd2-dev \
    jackd2 \
    alsa-utils \
    # Plugin hosting
    ladspa-sdk \
    # Network
    libcurl4-openssl-dev \
    # Fonts
    libfreetype-dev \
    libfontconfig1-dev \
    # X11
    libx11-dev \
    libxcomposite-dev \
    libxcursor-dev \
    libxext-dev \
    libxinerama-dev \
    libxrandr-dev \
    libxrender-dev \
    # WebKit
    libwebkit2gtk-4.1-dev \
    # OpenGL
    libglu1-mesa-dev \
    mesa-common-dev \
    # Build tools
    ninja-build \
    pkg-config \
    clang-format \
    ccache \
    lldb \
    gdb \
    # Headless GUI testing
    xvfb \
    && apt-get autoremove -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Set Clang as default compiler (matches JuceDevMachine pattern)
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100

# Enable ccache for faster rebuilds
ENV PATH="/usr/lib/ccache:${PATH}"
