# docker build -t uwaang/lab_futter_image:1.0 --build-arg UID=$UID --build-arg USER_NAME=$USER -f Dockerfile .
# docker run -it --name lab_futter_cont02 -v  $PWD:/home/$USER/lab_flutter -w  /home/$USER/lab_flutter uwaang/lab_futter_image:1.0
# keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
# flutter create --platforms=android lab_flutter
# cp /workspace/main.dart lab_flutter/lib/main.dart
# cp /workspace/build.gradle lab_flutter/android/app/build.gradle
# cd lab_flutter && flutter build apk --release
# cp build/app/outputs/flutter-apk/app-release.apk /workspace/

FROM ubuntu:latest
LABEL maintainer "https://github.com/Uwaang"

ARG UID=1000
ARG USER_NAME=user

ENV DEBIAN_FRONTEND=noninteractive

# Needed for string substitution
SHELL ["/bin/bash", "-c"]
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    vim \
    sudo \
    wget \
    gnupg \
    lsb-release \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    openjdk-11-jdk \
    software-properties-common && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Chrome for Flutter Web
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
    apt-get update && \
    apt-get install -y google-chrome-stable

# Set JAVA_HOME environment variable
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64

# Download and install Flutter SDK
ENV FLUTTER_HOME /usr/local/flutter
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME
ENV PATH "$PATH:$FLUTTER_HOME/bin"

# Download and unpack Android SDK Command line tools
ENV ANDROID_HOME /usr/local/android-sdk
RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip -d $ANDROID_HOME/cmdline-tools && \
    rm cmdline-tools.zip && \
    mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest

# Set environment variable
ENV PATH "$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"

# Install Android SDK components
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3"

# Change ownership of the Flutter SDK and Android SDK
RUN chown -R $UID:$UID $FLUTTER_HOME $ANDROID_HOME

# Create a user and configure sudoers
RUN adduser $USER_NAME --uid $UID --quiet --gecos "" --disabled-password && \
    mkdir -p /etc/sudoers.d && \
    echo "$USER_NAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USER_NAME && \
    chmod 0440 /etc/sudoers.d/$USER_NAME

USER $USER_NAME
#WORKDIR /home/$USER_NAME/app
SHELL ["/bin/bash", "-c"]
