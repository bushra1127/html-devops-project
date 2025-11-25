pipeline {
  agent any

  environment {
    DOCKER_REPO = "bushradockerhub/html-devops-project"
    DOCKER_CREDENTIALS_ID = 'dockerhub-creds'
    K8S_NAMESPACE = 'devops-demo'
    IMAGE_TAG = "${BUILD_NUMBER}"
    IMAGE = "${DOCKER_REPO}:${IMAGE_TAG}"
    KUBECONFIG = "/var/lib/jenkins/.kube/config"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        sh "docker build -t ${IMAGE} ."
      }
    }

    stage('Test Image') {
      steps {
        sh '''
          cid=$(docker create ${IMAGE})
          docker cp ${cid}:/usr/share/nginx/html/index.html /tmp/index.html || true
          docker rm -v ${cid}
          if [ ! -f /tmp/index.html ]; then
            echo "index.html missing!"
            exit 1
          fi
        '''
      }
    }

    stage('Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: DOCKER_CREDENTIALS_ID,
          usernameVariable: 'USER',
          passwordVariable: 'PASS'
        )]) {
          sh '''
            echo "$PASS" | docker login -u "$USER" --password-stdin
            docker push ${IMAGE}
            docker logout
          '''
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh '''
        
          # Create namespace if missing
          kubectl get ns devops-demo || kubectl create ns devops-demo

          # Deploy using updated image
          sed "s|IMAGE_PLACEHOLDER|${IMAGE}|g" k8s/deployment.yaml | \
            kubectl -n devops-demo apply -f -

          kubectl -n devops-demo apply -f k8s/service.yaml

          if [ -f k8s/ingress.yaml ]; then
            kubectl -n devops-demo apply -f k8s/ingress.yaml
          fi
        '''
      }
    }

  }

  post {
    success {
      echo "Deployment successful! Running image: ${IMAGE}"
    }
    failure {
      echo "Deployment failed!"
    }
  }
}
