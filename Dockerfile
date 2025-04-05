# Use the Eclipse Temurin base image with JDK 17
FROM eclipse-temurin:17-jdk-jammy

# Create a non-root user for running the app securely
RUN useradd -m springuser

# Set working directory
WORKDIR /app

# ARG for the JAR file location (used at build time)
ARG JAR_FILE=target/*.jar

# Copy the built JAR file into the container
COPY ${JAR_FILE} app.jar

# Install kubectl
RUN apt-get update && apt-get install -y curl && \
    curl -LO https://dl.k8s.io/release/v1.24.0/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set proper permissions and switch to non-root user
RUN chown -R springuser:springuser /app
USER springuser

# Define the entrypoint to run the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]
