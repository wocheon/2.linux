FROM openjdk:8-jdk

ENV TOMCAT_VERSION "8.5.99"
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH

RUN mkdir -p "$CATALINA_HOME"

ADD packages/mariadb-java-client-2.7.9.jar /usr/local/openjdk-8/lib/
ADD packages/mariadb-java-client-2.7.9.jar /usr/local/tomcat/lib/
COPY packages/apache-tomcat-${TOMCAT_VERSION}.tar.gz ${CATALINA_HOME}

WORKDIR ${CATALINA_HOME}

RUN apt-get install -y wget

#RUN wget https://dlcdn.apache.org/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz;
RUN tar -xf "apache-tomcat-${TOMCAT_VERSION}.tar.gz"  --strip-components=1;

RUN find . -name "*.bat" -exec rm -rf {} \;
RUN rm -rf *tomcat*.tar.gz;
RUN mv webapps webapps.org
RUN mkdir webapps

#COPY ./target/test/index.jsp $CATALINA_HOME/webapps/ROOT/
COPY ./target/ROOT.war $CATALINA_HOME/webapps
EXPOSE 8080
CMD ["catalina.sh", "run"]
