
podTemplate(label: 'bmi-calculator-build-pod', containers: [
        containerTemplate(name: 'git', image: 'alpine/git', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'sonar-cli', image: 'sonarsource/sonar-scanner-cli:latest', command: 'cat', ttyEnabled: true),
        containerTemplate(name: 'node-alpine', image: 'node:16.13.1-alpine', command: 'cat', ttyEnabled: true)
    ]) {
    node('bmi-calculator-build-pod') {
        stage('Clone Repository') {
            container('git') {
                sh 'whoami'
                sh 'hostname -i'
                sh 'git clone -b master https://github.com/kelumkps/bmi-calculator.git'
            }
        }

        stage('Install Dependencies') {
            container('node-alpine') {
                sh 'hostname -i'
                sh 'node --version'
                sh 'pwd'
                sh 'ls -la'
                sh 'npm ci --prefix ./bmi-calculator'
            }
        }

        stage('Test') {
            container('node-alpine') {
                sh 'hostname -i'
                sh 'node --version'
                sh 'pwd'
                sh 'ls -la'
                sh 'cd ./bmi-calculator; npm test -- --coverage --watchAll=false'
            }
            cobertura coberturaReportFile: 'bmi-calculator/coverage/cobertura-coverage.xml', enableNewApi: true, lineCoverageTargets: '50, 50, 50', conditionalCoverageTargets: '70, 0, 0', methodCoverageTargets: '80, 0, 0'
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
            timeout(time: 30, unit: 'MINUTES') {
                def qg = waitForQualityGate()
                if (qg.status != 'OK') {
                  error "Pipeline aborted due to quality gate failure: ${qg.status}"
                }
            }
        }
    }
}
