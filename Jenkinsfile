pipeline {
  agent {
    docker {
      image 'maven:3.9.4-eclipse-temurin-17'
      args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  environment {
    DOCKER_REGISTRY = 'sbenaissa'
    APP_NAME = 'spring-demo'
    DOCKER_IMAGE = "${DOCKER_REGISTRY}/${APP_NAME}"
    KUBE_NAMESPACE = 'default'
    KUBE_CONTEXT = 'minikube'
    TAG = "${BUILD_ID}"
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
          env.COMMIT_HASH = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
          def commitMessage = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim()
          echo "🔍 Commit Hash: ${env.COMMIT_HASH}"
          echo "📝 Commit Message: ${commitMessage}"
          currentBuild.displayName = "#${env.TAG}-${env.COMMIT_HASH}"
        }
      }
    }

    stage('Build App') {
      steps {
        sh 'mvn clean package -DskipTests'
        archiveArtifacts artifacts: 'target/*.jar'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh """
          DOCKER_BUILDKIT=1 docker build \
            -t ${DOCKER_IMAGE}:${TAG} \
            -t ${DOCKER_IMAGE}:latest \
            --label commit=${COMMIT_HASH} \
            .
        """
      }
    }

    stage('Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'dockerhub-creds',
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS'
        )]) {
          sh """
            echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
            docker push ${DOCKER_IMAGE}:${TAG}
          """
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh """
          kubectl config use-context ${KUBE_CONTEXT}
          kubectl config set-context --current --namespace=${KUBE_NAMESPACE}
          sed 's|__TAG__|${TAG}|g' k8s/deployment.yaml > k8s/rendered-deployment.yaml
          kubectl apply -f k8s/rendered-deployment.yaml
          kubectl apply -f k8s/service.yaml
        """
      }
    }

    stage('Verify Deployment') {
      steps {
        script {
          sh "kubectl rollout status deployment/${APP_NAME} --timeout=300s"

          def pods = sh(script: "kubectl get pods -l app=${APP_NAME} -o jsonpath='{.items[*].status.phase}'", returnStdout: true).trim()
          echo "📦 Pod Status: ${pods}"

          def servicePort = sh(script: "kubectl get svc ${APP_NAME} -o jsonpath='{.spec.ports[0].port}'", returnStdout: true).trim()
          def serviceIP = sh(script: "kubectl get svc ${APP_NAME} -o jsonpath='{.spec.clusterIP}'", returnStdout: true).trim()
          echo "🌐 Internal Service URL: http://${serviceIP}:${servicePort}"
        }
      }
    }
  }

  post {
    success {
      echo "✅ Deployment successful! Tag: ${TAG}"
    }
    failure {
      echo "❌ Deployment failed!"
      script {
        sh "kubectl rollout undo deployment/${APP_NAME} || true"
      }
    }
  }
}
