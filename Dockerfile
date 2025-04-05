# Use the Eclipse Temurin base image with JDK 17
FROM eclipse-temurin:17-jdk-jammy

# ARG for the JAR file location
ARG JAR_FILE=target/*.jar

# Copy the JAR file from the target directory to the container
COPY ${JAR_FILE} app.jar

# Install kubectl inside the container to enable Kubernetes commands
RUN apt-get update && apt-get install -y curl && \
    curl -LO https://dl.k8s.io/release/v1.24.0/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# Define the entrypoint to run the Spring Boot application
ENTRYPOINT ["java", "-jar", "/app.jar"]
