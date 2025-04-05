pipeline {
    agent {
        docker {
            image 'maven:3.9.4-eclipse-temurin-17'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        DOCKER_IMAGE = 'sbenaissa/spring-demo'
        KUBE_CONTEXT = 'docker-desktop'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Print Commit Details') {
            steps {
                script {
                    // Retrieve the commit hash and message
                    def commitHash = sh(script: "git rev-parse HEAD", returnStdout: true).trim()
                    def commitMessage = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim()
                    
                    // Display commit details in the Jenkins log
                    echo "Commit Hash: ${commitHash}"
                    echo "Commit Message: ${commitMessage}"
                }
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
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push $DOCKER_IMAGE:$BUILD_NUMBER
                    '''
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
