pipeline {
    agent {
        docker {
            image 'eclipse-temurin:8-jre-ubi9-minimal' 
            args '-v /root/.m2:/root/.m2' 
        }
    }
    stages {
        stage('Build') { 
            steps {
                sh 'mvn -B -DskipTests clean package' 
            }
        }
    }
}