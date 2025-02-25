
podTemplate(label: 'bmi-calculator-build-pod', containers: [
        containerTemplate(name: 'git', image: 'alpine/git', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'sonar-cli', image: 'sonarsource/sonar-scanner-cli:latest', command: 'cat', ttyEnabled: true),
        containerTemplate(name: 'node-alpine', image: 'node:16.13.1-alpine', command: 'cat', ttyEnabled: true),
        containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
        containerTemplate(name: 'trivy', image: 'aquasec/trivy:latest', command: 'cat', ttyEnabled: true),
        containerTemplate(name: 'kubectl', image: 'atlassian/pipelines-kubectl', command: 'cat', ttyEnabled: true),
        containerTemplate(name: 'blazemeter', image: 'blazemeter/taurus', command: 'cat', ttyEnabled: true)
    ],
    volumes: [
        hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
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
            cobertura coberturaReportFile: 'bmi-calculator/coverage/cobertura-coverage.xml', enableNewApi: true, lineCoverageTargets: '50, 50, 50', conditionalCoverageTargets: '60, 0, 0', methodCoverageTargets: '60, 0, 0'
            archiveArtifacts artifacts: 'bmi-calculator/coverage/cobertura-coverage.xml', fingerprint: true
        }

        stage('Quality Analysis') {
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
                  error 'Pipeline aborted due to quality gate failure: ${qg.status}'
                }
            }
        }

        stage('Build') {
            container('node-alpine') {
                sh 'hostname -i'
                sh 'node --version'
                sh 'pwd'
                sh 'ls -la'
                sh 'cd ./bmi-calculator; npm run build'
                sh 'cp ./bmi-calculator/Dockerfile ./bmi-calculator/build'
                sh 'ls -la ./bmi-calculator/build'
            }
            zip zipFile: 'build.zip', archive: true, dir: 'bmi-calculator/build'
            archiveArtifacts artifacts: 'build.zip', fingerprint: true
            stash name: 'builtArtifacts', includes: 'build.zip', allowEmpty: false
            slackSend channel: 'C12345679', color: 'good', message: 'The pipeline ${currentBuild.fullDisplayName} built successfully.'
        }

        stage('Docker Image') {
            unstash name: 'builtArtifacts'
            unzip zipFile: 'build.zip', dir: 'build'
            container('docker') {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh 'hostname -i'
                    sh 'ls -la'
                    sh 'ls -la build'
                    sh 'echo $BUILD_NUMBER'
                    sh 'docker --version'
                    sh 'docker login -u $USERNAME -p $PASSWORD'
                    sh 'docker build --tag bmi-calculator:$BUILD_NUMBER ./build'
                    sh 'docker tag bmi-calculator:$BUILD_NUMBER docker.io/kelumkps/bmi-calculator:latest'
                    sh 'docker tag bmi-calculator:$BUILD_NUMBER docker.io/kelumkps/bmi-calculator:$BUILD_NUMBER'
                    sh 'docker push -a docker.io/kelumkps/bmi-calculator'
                    sh 'docker logout'
                }
            }
        }

        stage('Docker Scan') {
            container('trivy') {
                sh 'hostname -i'
                sh 'trivy image -f json -o results.json kelumkps/bmi-calculator:$BUILD_NUMBER'
                recordIssues(tools: [trivy(pattern: 'results.json')])
            }
        }

        stage('Deploy') {
            container('kubectl') {
                withKubeConfig([credentialsId: 'minikube-k8s-token', serverUrl: 'https://kubernetes.default.svc.cluster.local']) {
                    sh 'hostname -i'
                    sh 'kubectl version'
                    sh 'ls -la'
                    sh 'ls -la bmi-calculator'
                    sh 'kubectl apply -f bmi-calculator/k8s-deployment.yaml'
                }
            }
        }

        stage('Performance Test') {
            container('blazemeter') {
                sh 'hostname -i'
                timeout(time: 10, unit: 'MINUTES') {
                    input message: 'Execute Performance Tests?'
                }
                sh 'bzt bmi-calculator/taurus-performance-test.yaml'
                sh 'ls -la'
                perfReport 'react-bmi-calculator-perf-test.xml'
            }
        }
    }
}
