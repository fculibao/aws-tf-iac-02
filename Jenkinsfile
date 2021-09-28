pipeline {
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    agent any

    stages {
        stage('Checkout') {
            steps {
            checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/fculibao/aws-tf-iac-02.git']]])            

          }
        }
        stage('Build Docker Image') {
            steps {
                echo 'Building Image.....'
                sh 'docker build -t fculibao/nginx:2.0.0 .'
            }
        }
        stage('Mvn Pacakge Test') {
            steps {
                echo 'Performing Test....'
                script {
                    def mvnHome = tool name: 'maven-3.8.2', type: 'maven'
                    def mvnCMD = "${mvnHome}/bin/mvn"
                    sh "${mvnCMD} clean package"
                } 
            }
        }
        stage('Push Docker Image') {
            steps {
                echo 'Pushing New Images.....'
                script {
                    withCredentials([string(credentialsId: 'docker-access-pwd', variable: 'dockerHubPwd')]) {
                    sh "docker login -u fculibao -p ${dockerHubPwd}"
                    }
                    sh 'docker push fculibao/nginx:2.0.0'
                }            
            }
        }
        stage ("terraform init") {
            steps {
                sh ('/usr/local/bin/terraform init')
            }
        }
        
        stage ("terraform Action") {
            steps {
                echo "Terraform action is --> ${action}"
                sh ('/usr/local/bin/terraform ${action} --auto-approve')
           }
        }
        stage('Deploy Docker Container into AWS EC2 Instance') {
            steps {
                echo 'Deploying....'
                script {
                    sh "terraform state show aws_eip.one | grep public_ip | awk 'NR==1{print \$3}' | sed 's/"//g' > instance_pub_ip"
                    def dockerRun = 'docker run -p 80:80 -d --name web-server fculibao/nginx:2.0.0'
                    sshagent(['ubuntu']) {
                    sh "ssh -o StrictHostKeyChecking=no ubuntu@\$instance_pub_ip ${dockerRun}"
                    }
                }
            }
        }    
    }
}