FROM openjdk:8
EXPOSE 8080
ADD target/aws-tf-iac-02.jar aws-tf-iac-02.jar
ENTRYPOINT ["java","-jar","/aws-tf-iac-02.jar"]

