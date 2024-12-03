pipeline {
    agent any
    stages {
        stage("test") {
            steps {
                
                script {
                        def output = sh(returnStdout: true, script: 'echo $(echo $GIT_BRANCH   | sed -e "s|origin/||g")')
                        GIT_LOCAL_BRANCH="${output}"
                    }

                build job: 'Django test parametrized',
                    parameters: [
                        string(name: 'GIT_URL', value: "${GIT_URL}"),
                        string(name: 'GIT_BRANCH', value: "${GIT_LOCAL_BRANCH}")
                    ]
            }
        }
    }
}