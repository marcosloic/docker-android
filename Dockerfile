FROM ubuntu:16.04

LABEL maintainer "marcosloic@gmail.com"

# support multiarch: i386 architecture
# install Java
# install essential tools
# install Qt
RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y lib32stdc++6 lib32z1 && \
    apt-get install -y --no-install-recommends openjdk-8-jdk && \
    apt-get install -y git wget zip curl && \
    apt-get install -y kvm qemu-kvm git

RUN curl https://nodejs.org/dist/v10.13.0/node-v10.13.0-linux-x64.tar.gz | tar xz -C /usr/local/ --strip=1
RUN npm i -g cordova

# Expose ADB, ADB control and VNC ports
EXPOSE 22
EXPOSE 5037
EXPOSE 5554
EXPOSE 5555
EXPOSE 5900
EXPOSE 80
EXPOSE 443

# download and install Gradle
# https://services.gradle.org/distributions/
ENV GRADLE_VERSION 4.10
RUN cd /opt && \
    wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip gradle*.zip && \
    ls -d */ | sed 's/\/*$//g' | xargs -I{} mv {} gradle && \
    rm gradle*.zip

# download and install Android SDK
# https://developer.android.com/studio/#downloads
ENV ANDROID_SDK_VERSION 4333796
RUN mkdir -p /opt/android-sdk && cd /opt/android-sdk && \
    wget -q https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip && \
    unzip *tools*linux*.zip && \
    rm *tools*linux*.zip

# set the environment variables
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV GRADLE_HOME /opt/gradle
ENV ANDROID_HOME /opt/android-sdk
ENV PATH ${PATH}:${GRADLE_HOME}/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin
ENV _JAVA_OPTIONS -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap

# accept the license agreements of the SDK components
ADD license_accepter.sh /opt/
RUN /opt/license_accepter.sh $ANDROID_HOME
RUN echo y | /opt/android-sdk/tools/bin/sdkmanager "system-images;android-28;android-tv;x86"
RUN echo y | /opt/android-sdk/tools/bin/sdkmanager "build-tools;28.0.0"

#Removing emulator for now while I find a way to make hardware acceleration work on VM
#RUN echo y | /opt/android-sdk/tools/bin/sdkmanager "emulator"
#RUN echo "no" | /opt/android-sdk/tools/bin/avdmanager create avd --package "system-images;android-28;android-tv;x86" --name "tv"

#RUN cordova create test && cd test && cordova platform add android && cordova build
#ADD entrypoint.sh /entrypoint.sh
#RUN chmod +x /entrypoint.sh

#ADD kvm.sh /kvm.sh
#RUN chmod +x /kvm.sh

CMD ["bash"]
