FROM ubuntu:14.04

RUN apt-get update -qq
RUN apt-get install -y curl git

# Install Docker
RUN curl -sSL https://get.docker.io/ubuntu/ | sh

# Install Fig
RUN curl -L https://github.com/docker/fig/releases/download/0.5.2/linux > /usr/local/bin/fig
RUN chmod +x /usr/local/bin/fig

# Install buildbox-agent
RUN VERSION=1.0-beta.1 bash -c "`curl -sL https://raw.githubusercontent.com/buildbox/agent/master/install.sh`"
RUN ln -s /.buildbox/bin/buildbox /usr/local/bin/buildbox

# Use our fig-enabled bootstrap
ADD bootstrap.fig.sh /.buildbox/bootstrap.fig.sh
RUN chmod u+x /.buildbox/bootstrap.fig.sh
