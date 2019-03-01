FROM bats-jenkins

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
USER root
RUN rm -rf /usr/share/jenkins/jenkins.war
USER root
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
