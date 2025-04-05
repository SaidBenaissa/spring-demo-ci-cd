pipeline {
  agent {
    docker {
      image 'maven:3.9.4-eclipse-temurin-17'
      args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  environment {
    DOCKER_IMAGE = 'sbenaissa/spring-demo'
    KUBE_CONTEXT = 'minikube' // or 'docker-desktop'
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
          def commitHash = sh(script: "git rev-parse HEAD", returnStdout: true).trim()
          def commitMessage = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim()
          echo "🔍 Commit Hash: ${commitHash}"
          echo "📝 Commit Message: ${commitMessage}"
        }
      }
    }

    stage('Build App') {
      steps {
        sh 'mvn clean package -DskipTests'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
      }
    }

    stage('Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh """
            echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
            docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
          """
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh """
          kubectl config use-context ${KUBE_CONTEXT}
          sed 's|__TAG__|${BUILD_NUMBER}|' k8s/deployment.yaml | kubectl apply -f -
          kubectl apply -f k8s/service.yaml
        """
      }
    }

    stage('Confirm Rollout') {
      steps {
        sh "kubectl rollout status deployment/spring-demo"
        sh "kubectl get pods -l app=spring-demo"
      }
    }
  }
}
