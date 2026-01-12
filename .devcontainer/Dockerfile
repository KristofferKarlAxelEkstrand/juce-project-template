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
    # Static analysis (cppcheck from Debian, LLVM tools installed separately)
    cppcheck \
    # Build acceleration and debugging
    ccache \
    gdb \
    # Headless GUI testing
    xvfb \
    # Required for LLVM repository setup
    wget \
    gnupg \
    && apt-get autoremove -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Install LLVM 20 from official LLVM repository for modern C++ tooling
# Note: Uses development snapshot repository (llvm-toolchain-bookworm-20)
# Clang 20 includes RealtimeSanitizer and full Function Effect Analysis
# When LLVM 20 is released as stable, update to use the release repository
RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/llvm.gpg] https://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-20 main" \
    > /etc/apt/sources.list.d/llvm.list \
    && apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
    clang-20 \
    clang-format-20 \
    clang-tidy-20 \
    clangd-20 \
    lldb-20 \
    lld-20 \
    libclang-rt-20-dev \
    && apt-get autoremove -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    # Set LLVM 20 as default
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-20 100 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-20 100 \
    && update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-20 100 \
    && update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-20 100 \
    && update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-20 100 \
    && update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-20 100 \
    && update-alternatives --install /usr/bin/lld lld /usr/bin/lld-20 100 \
    # Set Clang as default compiler
    && update-alternatives --install /usr/bin/cc cc /usr/bin/clang-20 100 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-20 100

# Enable ccache for faster rebuilds
ENV PATH="/usr/lib/ccache:${PATH}"
