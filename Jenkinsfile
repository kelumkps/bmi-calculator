podTemplate(label: 'bmi-calculator-build-pod', containers: [
        containerTemplate(name: 'git', image: 'alpine/git', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'sonar-cli', image: 'sonarsource/sonar-scanner-cli:latest', command: 'cat', ttyEnabled: true),
//         containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true)
    ]/* ,
    volumes: [
        hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
    ] */) {
    node('bmi-calculator-build-pod') {
//         stage('Check running containers') {
//             container('docker') {
//                 // example to show you can run docker commands when you mount the socket
//                 sh 'hostname'
//                 sh 'hostname -i'
//             }
//         }

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
                    sh 'whoami'
                    sh 'ls -la'
                    sh 'hostname -i'
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
    }
}