FROM ubuntu:16.10
MAINTAINER Sasquatch Technology

ENV LANG en_US.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle

RUN apt-get update && apt-get -y install ca-certificates maven curl git xvfb wget chromium-browser build-essential software-properties-common

# Install Java.
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Install the Docker CLI
RUN curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose && \
    chmod +x /usr/bin/docker-compose && curl -fL -o docker.tgz "https://get.docker.com/builds/Linux/x86_64/docker-1.11.1.tgz";
RUN tar --extract --file docker.tgz --strip-components 1 --directory /usr/local/bin && rm docker.tgz

# Install node and gulp
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash && \
    apt-get -y install nodejs && \
    npm -g install gulp@3.9.1

RUN apt-get clean

CMD ["bash"]
