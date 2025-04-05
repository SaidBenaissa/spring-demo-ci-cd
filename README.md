# Spring Demo CI/CD Project

This project demonstrates a complete CI/CD pipeline for a Spring Boot application. It includes automated build, containerization, and deployment to a Kubernetes cluster using Jenkins and Docker.

## Features

- **Spring Boot Application**: A simple RESTful application built with Spring Boot.
- **CI/CD Pipeline**: A Jenkins pipeline automates the following steps:
  - Code checkout from GitHub.
  - Building the Spring Boot application using Maven.
  - Building and pushing a Docker image to Docker Hub.
  - Deploying the application to a Kubernetes cluster.
- **Kubernetes Deployment**: The application is deployed to a Kubernetes cluster using a `Deployment` and `Service` configuration.

## Project Structure

## Prerequisites

- **Docker**: Ensure Docker is installed and running.
- **Kubernetes**: A Kubernetes cluster (e.g., Minikube, Docker Desktop, or a cloud provider).
- **Jenkins**: A Jenkins server with Docker and Kubernetes CLI tools installed.
- **GitHub**: A GitHub repository for source code management.

## CI/CD Pipeline

The Jenkins pipeline (`Jenkinsfile`) automates the following steps:

1. **Checkout Code**: Retrieves the latest code from the GitHub repository.
2. **Build Application**: Uses Maven to build the Spring Boot application.
3. **Build Docker Image**: Creates a Docker image for the application.
4. **Push to Docker Hub**: Pushes the Docker image to a Docker Hub repository.
5. **Deploy to Kubernetes**: Updates the Kubernetes deployment with the new Docker image.

## Kubernetes Deployment

The Kubernetes configuration files (`k8s/deployment.yaml` and `k8s/service.yaml`) define the deployment and service for the application. The deployment uses the Docker image built in the CI/CD pipeline.

## How to Run Locally

1. Clone the repository:
   ```bash
   git clone https://github.com/SaidBenaissa/spring-demo-ci-cd.git
   cd spring-demo-ci-cd

2. Build the application:
   ```bash
    mvn clean package
    ```

3. Run the application:
    ```bash
    java -jar target/spring-demo-ci-cd-0.0.1-SNAPSHOT.jar
    ```

4. Access the application:
    Open your web browser and go to `http://localhost:8080/api/hello`.
    You should see a message saying "Hello, World!".
5. To run the application in Docker, build the Docker image:
    ```bash
    docker build -t spring-demo-ci-cd .
    ```
6. Access the application at http://localhost:8080.
    - Exposing Jenkins for GitHub Webhooks
    - To expose your local Jenkins server to the internet for GitHub webhooks, use a tunneling service like Serveo:
    - Replace localhost:8090 with your Jenkins server's local address and port.

License
This project is licensed under the MIT License. See the LICENSE file for details.

# Trigger deployment from clean slate
# Trigger deployment from clean slate
