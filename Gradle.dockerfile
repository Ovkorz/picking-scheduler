FROM eclipse-temurin:17-jdk-alpine

# Install OpenJDK 17
RUN apk add --no-cache openjdk17

# Set the JAVA_HOME environment variable
ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk

# Set the Gradle home environment variable
ENV GRADLE_HOME /opt/gradle

# Add the Gradle executable to the system PATH
ENV PATH "$PATH:$GRADLE_HOME/bin"


RUN set -o errexit -o nounset \
    && echo "Adding gradle user and group" \
    && addgroup --system gradle \
    && adduser --system --ingroup gradle --shell /bin/ash gradle \
    && mkdir /home/gradle/.gradle \
    && chown -R gradle:gradle /home/gradle \
    \
    && echo "Symlinking root Gradle cache to gradle Gradle cache" \
    && ln -s /home/gradle/.gradle /root/.gradle

VOLUME /home/gradle/.gradle

WORKDIR /home/gradle

RUN set -o errexit -o nounset \
    && echo "Installing VCSes" \
    && apk add --no-cache \
        unzip \
        wget \
        \
        bzr \
        git \
        git-lfs \
        mercurial \
        subversion \
        /
        docker.io \
        openssh-client \
        openssh-server \
    && rm --recursive --force /var/lib/apt/lists/* \
    \
    && echo "Testing VCSes" \
    && which git \
    && which git-lfs \
    && which hg \
    && which svn \
    && which docker

ENV GRADLE_VERSION 8.1.1
ARG GRADLE_DOWNLOAD_SHA256=e111cb9948407e26351227dabce49822fb88c37ee72f1d1582a69c68af2e702f
RUN set -o errexit -o nounset \
    && echo "Downloading Gradle" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    \
    && echo "Checking download hash" \
    && echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum --check - \
    \
    && echo "Installing Gradle" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
    && ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle \
    \
    && echo "Testing Gradle installation" \
    && gradle --version

RUN groupadd docker \
    && usermod -aG docker $USER \
    && newgrp docker

RUN docker -v
