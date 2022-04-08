pipeline {
    agent {
        docker {
            image 'sonarsource/sonar-scanner-cli:latest'
        }
    }
    stages {
        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate(abortPipeline: true, credentialsId: 'sonar-qube-access-token')
                }
            }
        }
    }
}