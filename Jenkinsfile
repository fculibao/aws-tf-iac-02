pipeline {
    parameters {
        string(name: 'environment', defaultValue: 'terraform', description: 'Workspace/environment file to use for deployment')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')

    }
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
        stage('Plan') {
            steps {
                sh  ('/usr/local/bin/terraform init -input=false')
                sh  ('/usr/local/bin/terraform workspace new ${environment}')
                sh  ('/usr/local/bin/terraform workspace select ${environment}')
                sh  ('/usr/local/bin/terraform plan -input=false -out tfplan')
                sh  ('/usr/local/bin/terraform show -no-color tfplan > tfplan.txt')
            }
        }
        stage('Approval') {
           when {
               not {
                   equals expected: true, actual: params.autoApprove
               }
           }

           steps {
               script {
                    def plan = readFile 'terraform/aws-instance-first-script/tfplan.txt'
                    input message: "Do you want to apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
               }
           }
        }
        
        stage ("terraform Action") {
            steps {
                echo "Terraform action is --> ${action}"
                sh ('/usr/local/bin/terraform ${action} --auto-approve')
           }
        }    
    }
}