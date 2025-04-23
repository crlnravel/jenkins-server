FROM jenkins/jenkins:lts-jdk17

# add ability to run docker from within jenkins (docker in docker)
USER root
RUN apt-get update && apt-get install -y lsb-release sudo
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y tini docker-ce-cli \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# set default user attributes (keep USER jenkins before this if preferred, but script runs as root initially)
ENV JENKINS_UID=1000
ENV JENKINS_GID=1000

# add entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh # Ensure it's executable

# Switch back to root because the entrypoint script needs to run chown/usermod etc.
USER root

# Use the correct path for tini and execute the custom entrypoint
ENTRYPOINT ["/usr/bin/tini", "--", "/docker-entrypoint.sh"]
