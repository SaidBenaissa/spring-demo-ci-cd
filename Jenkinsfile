pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'sbenaissa/spring-demo'
        KUBE_CONTEXT = 'docker-desktop'
    }

    //  CI/CD process
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Spring Boot App') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:$BUILD_NUMBER .'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker push $DOCKER_IMAGE:$BUILD_NUMBER'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                kubectl config use-context $KUBE_CONTEXT
                kubectl set image deployment/springboot-demo springboot-demo=$DOCKER_IMAGE:$BUILD_NUMBER
                """
            }
        }
    }
}
