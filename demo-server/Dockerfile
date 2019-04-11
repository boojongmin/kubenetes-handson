FROM openjdk:8-jdk-alpine
VOLUME /tmp
ARG JAR_FILE
COPY app.jar app.jar
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom", "-Dspring.profiles.active=default", "-jar","/app.jar"]
