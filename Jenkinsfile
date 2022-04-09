
podTemplate(label: 'bmi-calculator-build-pod', containers: [
        containerTemplate(name: 'git', image: 'alpine/git', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'sonar-cli', image: 'sonarsource/sonar-scanner-cli:latest', command: 'cat', ttyEnabled: true),
        containerTemplate(name: 'node-alpine', image: 'node:16.13.1-alpine', command: 'cat', ttyEnabled: true)
    ]) {
    node('bmi-calculator-build-pod') {
        stage('Clone repository') {
            container('git') {
                sh 'whoami'
                sh 'hostname -i'
                sh 'git clone -b master https://github.com/kelumkps/bmi-calculator.git'
            }
        }

        stage("Quality Analysis") {
            container('sonar-cli') {
                   withSonarQubeEnv('SonarQube-on-MiniKube') {
                    sh 'hostname -i'
                    sh 'ls -la'
                    sh 'pwd'
                    sh 'sonar-scanner -Dsonar.projectBaseDir=./bmi-calculator'
                }
            }
        }

        stage("Quality Gate"){
            timeout(time: 30, unit: 'MINUTES') {
                def qg = waitForQualityGate()
                if (qg.status != 'OK') {
                  error "Pipeline aborted due to quality gate failure: ${qg.status}"
                }
            }
        }

        stage('npm install') {
            container('node-alpine') {
                sh 'hostname -i'
                sh 'node --version'
                sh 'pwd'
                sh 'ls -la'
                sh 'npm install --prefix ./bmi-calculator'
            }
        }
    }
}

/*
pipeline {
    agent any
    stages {
        stage('SCA') {
            agent {
                docker {
                    image 'sonarsource/sonar-scanner-cli:latest'
                }
            }
            steps {
                echo "Steps to execute SCA"
                withSonarQubeEnv(installationName: 'SonarQube', credentialsId: 'sonar-qube-access-token') {
                    sh 'sonar-scanner -Dsonar.projectVersion=1.0 -Dsonar.projectKey=bmi-calculator -Dsonar.sources=src'
                }
                waitForQualityGate(abortPipeline: true, credentialsId: 'sonar-qube-access-token')
            }
        }
    }
} */
