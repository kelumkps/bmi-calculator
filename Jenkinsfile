// pipeline {
//     agent {
//         docker {
//             image 'sonarsource/sonar-scanner-cli:latest'
//         }
//     }
//     stages {
//         stage("Quality Gate") {
//             steps {
//                 timeout(time: 1, unit: 'HOURS') {
//                     waitForQualityGate(abortPipeline: true, credentialsId: 'sonar-qube-access-token')
//                 }
//             }
//         }
//     }
// }

pipeline {
    environment {
        SONAR_LOGIN = credentials('sonar-qube-access-token')
        SONAR_HOST_URL = 'sonarqube-sonarqube.sonarqube.svc.cluster.local:9000'
    }

    podTemplate(label: 'mypod', containers: [
        containerTemplate(name: 'git', image: 'alpine/git', ttyEnabled: true, command: 'cat'),
//         containerTemplate(name: 'sonar-cli', image: 'sonarsource/sonar-scanner-cli:latest', envVars: [
//             envVar(key: 'SONAR_HOST_URL', value: 'sonarqube-sonarqube.sonarqube.svc.cluster.local:9000'),
//             envVar(key: 'SONAR_LOGIN', value: credentials('sonar-qube-access-token'))
//         ], command: 'cat', ttyEnabled: true),
        containerTemplate(name: 'sonar-cli', image: 'sonarsource/sonar-scanner-cli:latest', command: 'cat', ttyEnabled: true),
        containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true)
      ],
      volumes: [
        hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
      ]
      ) {
        node('mypod') {
            stage('Check running containers') {
                container('docker') {
                    // example to show you can run docker commands when you mount the socket
                    sh 'hostname'
                    sh 'hostname -i'
                    sh 'docker ps'
                }
            }

            stage('Clone repository') {
                container('git') {
                    sh 'whoami'
                    sh 'hostname -i'
                    sh 'git clone -b master https://github.com/kelumkps/bmi-calculator.git'
                }
            }

            stage("Quality Gate") {
                container('sonar-cli') {
                    sh 'whoami'
                    sh 'hostname -i'
                    sh 'sonar-scanner'
                }
            }
        }
    }
}