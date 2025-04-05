pipeline {
  agent {
    docker {
      image 'maven:3.9.4-eclipse-temurin-17'
      args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  environment {
    DOCKER_REGISTRY = 'sbenaissa'  // Explicit registry
    APP_NAME = 'spring-demo'
    DOCKER_IMAGE = "${DOCKER_REGISTRY}/${APP_NAME}"
    KUBE_NAMESPACE = 'default'  // Explicit namespace
    KUBE_CONTEXT = 'minikube'   // or 'docker-desktop'
    // Use BUILD_ID for immutable tags (better than BUILD_NUMBER)
    TAG = "${env.BUILD_ID}"
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
          def commitHash = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()  // Short hash
          def commitMessage = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim()
          echo "🔍 Commit Hash: ${commitHash}"
          echo "📝 Commit Message: ${commitMessage}"
          // Set display name for Jenkins build
          currentBuild.displayName = "#${BUILD_ID}-${commitHash.take(7)}"
        }
      }
    }

    stage('Build App') {
      steps {
        sh 'mvn clean package -DskipTests'
        archiveArtifacts 'target/*.jar'  // Save build artifacts
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          // Use Docker BuildKit for better caching/security
          sh """
            DOCKER_BUILDKIT=1 docker build \
              -t ${DOCKER_IMAGE}:${TAG} \
              -t ${DOCKER_IMAGE}:latest \
              --label "commit=${commitHash}" \
              .
          """
        }
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
            docker push ${DOCKER_IMAGE}:latest  // Optional
          """
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        script {
          // Apply all manifests in order (deployment, service, ingress, etc.)
          sh """
            kubectl config use-context ${KUBE_CONTEXT}
            kubectl config set-context --current --namespace=${KUBE_NAMESPACE}
            sed 's|__TAG__|${TAG}|g' k8s/deployment.yaml | kubectl apply -f -
            kubectl apply -f k8s/service.yaml
            # Add other manifests (e.g., ingress) if needed
          """
        }
      }
    }

    stage('Verify Deployment') {
      steps {
        script {
          // Wait for rollout (with timeout)
          sh "kubectl rollout status deployment/${APP_NAME} --timeout=300s"
          
          // Verify pod status
          def pods = sh(script: "kubectl get pods -l app=${APP_NAME} -o jsonpath='{.items[*].status.phase}'", returnStdout: true).trim()
          echo "📦 Pod Status: ${pods}"

          // Optional: Smoke test (e.g., curl endpoint)
          def serviceUrl = sh(script: "kubectl get svc ${APP_NAME} -o jsonpath='{.spec.clusterIP}:{.spec.ports[0].port}'", returnStdout: true).trim()
          echo "🌐 Service URL: http://${serviceUrl}"
        }
      }
    }
  }

  post {
    success {
      echo "✅ Deployment successful! Build: ${TAG}"
      slackSend(color: 'good', message: "SUCCESS: ${APP_NAME} deployed (${TAG})")
    }
    failure {
      echo "❌ Deployment failed!"
      slackSend(color: 'danger', message: "FAILED: ${APP_NAME} deployment (${TAG})")
      // Optional: Rollback to previous version
      sh "kubectl rollout undo deployment/${APP_NAME}"
    }
  }
}