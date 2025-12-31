pipeline {
    agent any

    environment {
        IMAGE_NAME  = "cicd-website"
        DEV_PORT    = "8081"
        PROD_PORT   = "8082"
        MAIL_TO     = "priyajoshi6721@gmail.com"
        APPROVED_BY = "N/A"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ."
            }
        }

        stage('Deploy to DEV') {
            steps {
                sh """
                  docker rm -f dev-site || true
                  docker run -d --name dev-site -p ${DEV_PORT}:80 ${IMAGE_NAME}:${BUILD_NUMBER}
                """
            }
        }

        stage('Test in DEV') {
            steps {
                script {
                    try {
                        sh """
                          echo "Testing DEV environment..."
                          sleep 5
                          curl -f http://localhost:${DEV_PORT}
                        """
                    } catch (err) {
                        emailext(
                            to: env.MAIL_TO,
                            subject: "❌ DEV TEST FAILED | Build #${BUILD_NUMBER}",
                            body: """
DEV testing failed.

Job: ${JOB_NAME}
Build: ${BUILD_NUMBER}
URL: ${BUILD_URL}
"""
                        )
                        error("DEV tests failed")
                    }
                }
            }
        }

        stage('Manual Approval for PROD') {
            steps {
                script {
                    emailext(
                        to: env.MAIL_TO,
                        subject: "⏸ PROD Approval Required | Build #${BUILD_NUMBER}",
                        body: """
Approval needed for PROD deployment.

Job: ${JOB_NAME}
Build: ${BUILD_NUMBER}
URL: ${BUILD_URL}
"""
                    )

                    def approver = input(
                        message: "Approve deployment to PROD?",
                        ok: "Approve",
                        submitter: "manager",
                        submitterParameter: "APPROVER"
                    )

                    env.APPROVED_BY = approver
                }
            }
        }

        stage('Deploy to PROD') {
            steps {
                sh """
                  docker rm -f prod-site || true
                  docker run -d --name prod-site -p ${PROD_PORT}:80 ${IMAGE_NAME}:${BUILD_NUMBER}
                """
            }
        }
    }

    post {
        success {
            emailext(
                to: env.MAIL_TO,
                subject: "✅ PROD DEPLOYED SUCCESSFULLY | Build #${BUILD_NUMBER}",
                body: """
Deployment successful.

Job: ${JOB_NAME}
Build: ${BUILD_NUMBER}
Approved by: ${env.APPROVED_BY}

URL: ${BUILD_URL}
"""
            )
        }

        failure {
            emailext(
                to: env.MAIL_TO,
                subject: "❌ PIPELINE FAILED | Build #${BUILD_NUMBER}",
                body: """
Pipeline failed.

Job: ${JOB_NAME}
Build: ${BUILD_NUMBER}
URL: ${BUILD_URL}
"""
            )
        }
    }
}
