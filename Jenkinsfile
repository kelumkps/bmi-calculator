
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
                sh 'git clone -b master https://github.com/kelumkps/bmi-calculator.git .'
            }
        }

        stage('Build') {
            container('node-alpine') {
                sh 'hostname -i'
                sh 'node --version'
                sh 'pwd'
                sh 'ls -la'
                sh 'npm install'
            }
        }

        stage('Test') {
            container('node-alpine') {
                sh 'hostname -i'
                sh 'node --version'
                sh 'pwd'
                sh 'ls -la'
                sh 'npm test -- --coverage --watchAll=false'
            }
            cobertura coberturaReportFile: 'coverage/cobertura-coverage.xml', enableNewApi: true, lineCoverageTargets: '50, 50, 50'
        }

        stage("Quality Analysis") {
            container('sonar-cli') {
                withSonarQubeEnv('SonarQube-on-MiniKube') {
                    sh 'hostname -i'
                    sh 'ls -la'
                    sh 'pwd'
                    sh 'sonar-scanner'
                }
            }
            timeout(time: 30, unit: 'MINUTES') {
                def qg = waitForQualityGate()
                if (qg.status != 'OK') {
                  error "Pipeline aborted due to quality gate failure: ${qg.status}"
                }
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
