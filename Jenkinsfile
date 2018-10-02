#!/usr/bin/env groovy
node {
  def project = 'pimenta'

  def appName = 'app'
  def project_id = "${project}-success"
  def image = "gcr.io/${project_id}/website"
  def imageTag = "${image}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"

  checkout scm

  stage('Build image'){
    sh("docker build -t ${imageTag} .")
  }

  withCredentials([file(credentialsId: "${project}", variable: 'key')]) {
    withEnv(["GOOGLE_APPLICATION_CREDENTIALS=${key}"]) {
      sh("gcloud auth activate-service-account --key-file ${key} --project=${project_id}")
      sh("gcloud container clusters get-credentials ${project} --zone europe-west1-b")

      stage('Push image to registry') {
        sh("gcloud docker -- push ${imageTag}")
      }

      stage('Deploy Application') {
        switch (env.BRANCH_NAME) {
          case "master":
            sh("sed -i.bak 's|##image##|${imageTag}|' ./k8s/website-deploy.yaml")
            sh("sed -i.bak 's|##namespace##|website-production|' ./k8s/website-deploy.yaml")
            sh("kubectl apply -f k8s/website-deploy.yaml")
            break
          case "develop":
            sh("sed -i.bak 's|##image##|${imageTag}|' ./k8s/website-deploy.yaml")
            sh("sed -i.bak 's|##namespace##|website-staging|' ./k8s/website-deploy.yaml")
            sh("kubectl apply -f k8s/website-deploy.yaml")
            break
        }
      }
    }
  }
}
