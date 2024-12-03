pipeline {
    agent any
    stages {
        stage("test") {
            steps {

                build job: 'Django test parametrized',
                    parameters: [
                        string(name: 'GIT_URL', value: "${GIT_URL}"),
                        string(name: 'GIT_BRANCH', value: get_branch_name())
                    ]
            }
        }
    }


}
String get_branch_name() {
        def output = sh(returnStdout: true, script: 'echo $(echo $GIT_BRANCH   | sed -e "s|origin/||g")')
    return "${output}"      
}