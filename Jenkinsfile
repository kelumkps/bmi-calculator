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


podTemplate(label: 'mypod', containers: [
    containerTemplate(name: 'git', image: 'alpine/git', ttyEnabled: true, command: 'cat'),
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

    //         stage('Clone repository') {
    //             container('git') {
    //                 sh 'whoami'
    //                 sh 'hostname -i'
    //                 sh 'git clone -b master https://github.com/lvthillo/hello-world-war.git'
    //             }
    //         }

        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate(abortPipeline: true, credentialsId: 'sonar-qube-access-token')
                }
            }
        }
    }
}