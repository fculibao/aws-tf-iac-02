FROM openjdk:8
EXPOSE 8080
ADD target/sample-integration.jar sample-integration.jar
ENTRYPOINT ["java","-jar","/sample-integration.jar"]

