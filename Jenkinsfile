pipeline {
    agent any

    environment {
        IMAGE_NAME = "cicd-website"
        DEV_PORT   = "8081"
        PROD_PORT  = "8082"

        NOTIFY_EMAIL = "priyajoshi6721@gmail.com"
    }

    stages {

        stage('Checkout Source Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$BUILD_NUMBER .'
            }
        }

        stage('Deploy to DEV') {
            steps {
                script {
                    try {
                        sh '''
                        docker rm -f dev-site || true
                        docker run -d --name dev-site -p $DEV_PORT:80 $IMAGE_NAME:$BUILD_NUMBER
                        '''
                    } catch (err) {
                        emailext(
                            subject: "❌ DEV DEPLOYMENT FAILED",
                            body: """
                            DEV deployment failed.

                            Job: ${JOB_NAME}
                            Build: ${BUILD_NUMBER}
                            Stage: DEV
                            """,
                            to: "$NOTIFY_EMAIL"
                        )
                        error "DEV deployment failed"
                    }
                }
            }
        }

        stage('Test Website') {
            steps {
                script {
                    try {
                        sh 'chmod +x test.sh'
                        sh './test.sh'
                    } catch (err) {
                        emailext(
                            subject: "❌ TEST FAILED",
                            body: """
                            Automated tests failed.

                            Job: ${JOB_NAME}
                            Build: ${BUILD_NUMBER}
                            Stage: TEST
                            """,
                            to: "$NOTIFY_EMAIL"
                        )
                        error "Tests failed"
                    }
                }
            }
        }

        stage('Manual Approval for PROD') {
            steps {
                emailext(
                    subject: "⏸ APPROVAL REQUIRED FOR PROD",
                    body: """
                    Pipeline is waiting for PROD approval.

                    Job: ${JOB_NAME}
                    Build: ${BUILD_NUMBER}
                    Stage: APPROVAL
                    """,
                    to: "$NOTIFY_EMAIL"
                )

                input message: 'Approve PROD website deployment?',
                      ok: 'Approve'
            }
        }

        stage('Deploy to PROD') {
            steps {
                script {
                    try {
                        sh '''
                        docker rm -f prod-site || true
                        docker run -d --name prod-site -p $PROD_PORT:80 $IMAGE_NAME:$BUILD_NUMBER
                        '''
                    } catch (err) {
                        emailext(
                            subject: "❌ PROD DEPLOYMENT FAILED",
                            body: """
                            PROD deployment failed.

                            Job: ${JOB_NAME}
                            Build: ${BUILD_NUMBER}
                            Stage: PROD
                            """,
                            to: "$NOTIFY_EMAIL"
                        )
                        error "PROD deployment failed"
                    }
                }
            }
        }
    }

    post {
        success {
            emailext(
                subject: "✅ PROD DEPLOYMENT SUCCESSFUL",
                body: """
                Website deployed successfully to PROD.

                Job: ${JOB_NAME}
                Build: ${BUILD_NUMBER}
                PROD URL: http://localhost:${PROD_PORT}
                """,
                to: "$NOTIFY_EMAIL"
            )
        }

        failure {
            emailext(
                subject: "❌ PIPELINE FAILED",
                body: """
                Jenkins pipeline failed.

                Job: ${JOB_NAME}
                Build: ${BUILD_NUMBER}
                Please check Jenkins logs.
                """,
                to: "$NOTIFY_EMAIL"
            )
        }
    }
}
