pipeline {
    agent any
    environment {
        IMAGE_NAME = "iorp/django_demo"
        PROD_CRED_ID = "devops_prod_key"
        PROD_ADDRESS_CRED_ID = "devops_prod_address"
        SONAR_CRED_ID = "sonar_token"
        PROJECT_NAME = "common_django"
        DOMAIN = "common.prod.mshp-devops.com"
        SONARQUBE_URL = "84.201.184.207:9001"
        SONAR_PROJECT_KEY = "django_common"
    }
    stages {
        stage("test") {
            steps {
                build job: '/lib/django-test-parametrized',
                    parameters: [
                        string(name: 'GIT_URL', value: "${GIT_URL}"),
                        string(name: 'GIT_BRANCH', value: "${GIT_BRANCH}")
                    ]
            }
        }
        stage("scan") {
            steps {
                withCredentials(
                    [
                        string(credentialsId: "${SONAR_CRED_ID}", variable:'TOKEN')
                    ]
                        ) {
                    sh '''
                            docker run \
                    --rm \
                    -e SONAR_HOST_URL="http://${SONARQUBE_URL}" \
                    -e SONAR_SCANNER_OPTS="-Dsonar.projectKey=${SONAR_PROJECT_KEY}" \
                    -e SONAR_TOKEN="${TOKEN}" \
                    -v "./:/usr/src" \
                    sonarsource/sonar-scanner-cli
                '''
                }
            }
        }
        stage("build") {
            steps {
                build job: '/lib/django build parametrized',
                    parameters: [
                        string(name: 'GIT_URL', value: "${GIT_URL}"),
                        string(name: 'GIT_BRANCH', value: "${GIT_BRANCH}"),
                        string(name: 'IMAGE_NAME', value: "${IMAGE_NAME}"),
                        string(name: 'GIT_COMMIT_HASH', value: "${GIT_COMMIT}")
                    ]
            }
        }
        stage("push") {
            steps {
                withCredentials(
                    [
                        usernamePassword(usernameVariable: 'LOGIN', passwordVariable: 'PASSWORD', credentialsId: 'iorp_dockerhub')
                        ]
                    ) {
                        sh 'docker login -u ${LOGIN} -p ${PASSWORD}'
                        sh 'docker push ${IMAGE_NAME}:latest'
                        sh 'docker push ${IMAGE_NAME}:${GIT_COMMIT}'
                    }
            }
        }
        stage("deploy") {
            steps {
                withCredentials(
                    [
                        sshUserPrivateKey(credentialsId: "${PROD_CRED_ID}", keyFileVariable: 'KEY_FILE', usernameVariable:'USERNAME'),
                        string(credentialsId: "${PROD_ADDRESS_CRED_ID}", variable:'SERVER_ADDRESS')
                    ]
                        ) {
                    sh 'ssh -o StrictHostKeyChecking=no -i "${KEY_FILE}" ${USERNAME}@${SERVER_ADDRESS} mkdir -p ${PROJECT_NAME}'
                    sh 'scp -o StrictHostKeyChecking=no -i "${KEY_FILE}" docker-compose.yaml ${USERNAME}@${SERVER_ADDRESS}:${PROJECT_NAME}/'
                    sh 'ssh -o StrictHostKeyChecking=no -i "${KEY_FILE}" ${USERNAME}@${SERVER_ADDRESS} docker compose -f ${PROJECT_NAME}/docker-compose.yaml pull'
                    sh 'ssh -o StrictHostKeyChecking=no -i "${KEY_FILE}" ${USERNAME}@${SERVER_ADDRESS} docker compose -f ${PROJECT_NAME}/docker-compose.yaml up -d'
                    sh 'scp -o StrictHostKeyChecking=no -i "${KEY_FILE}" common.prod.mshp-devops.com.conf ${USERNAME}@${SERVER_ADDRESS}:nginx'
                    sh 'ssh -o StrictHostKeyChecking=no -i "${KEY_FILE}" ${USERNAME}@${SERVER_ADDRESS} sudo certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos -m test@test.com'
                    sh 'ssh -o StrictHostKeyChecking=no -i "${KEY_FILE}" ${USERNAME}@${SERVER_ADDRESS} sudo systemctl reload nginx'
                }
            }
        }
    }
}
