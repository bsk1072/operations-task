def elb_dns
pipeline {
    agent {
        label "ubuntu"
    }
    parameters {
        choice(
                name: 'Action',
                choices: ['Apply', 'Destroy', 'Image'],
                description: 'Terraform action'
        )
    }
    stages {
        stage('Checkout code from repository') {
            when {
                expression { params.Action == 'Image' }
            }
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[credentialsId: 'gitCredbsk1072', url: 'https://github.com/bsk1072/operations-task.git']]])
                echo "checkout code from repository"
            }
        }

        stage('push docker image to ECR') {
            when {
                expression { params.Action == 'Image' }
            }
            steps {
                script {
                    withDockerRegistry(credentialsId: 'ecr:eu-west-1:awsCredAWS', url: 'http://182313166565.dkr.ecr.eu-west-1.amazonaws.com') {
                        def ratesImage = docker.build('182313166565.dkr.ecr.eu-west-1.amazonaws.com/rates-ecr')
                        ratesImage.push()
                        echo "Build and push image to ecr"
                    }
                }
            }
        }

        stage('Provision Infra and Deploy Services - Terraform init') {
            when {
                expression { params.Action != 'Destroy' }
            }
            steps {
                script {
                    sh "terraform init"
                    echo "initialize the terraform backend modules"
                }
            }
        }

        stage('Provision Infra and Deploy Services - Terraform plan') {
            when {
                expression { params.Action != 'Destroy' }
            }
            steps {
                script {
                    sh "terraform plan -destroy --var-file=development.tfvars -out terraform.plan"
                    echo "plan the terraform modules"
                }
            }
        }

        stage('Provision Infra and Deploy Services - Terraform apply') {
            when {
                expression { params.Action != 'Destroy' }
            }
            steps {
                script {
                    elb_dns = terraApply()
                    echo "infra provisioning with loadbalacing dns - ${elb_dns}. Use this url to access to rates application"
                }
            }
        }

        stage('Provision Infra and Deploy Services - Terraform Destroy') {
            when {
                expression { params.Action == 'Destroy' }
            }
            steps {
                script {
                    sh "terraform destroy --var-file=development.tfvars --auto-approve"
                    echo "destroy the infra with earlier changes"
                }
            }
        }
    }
}

def terraApply(){
    def rates_elb_dns
    sh "terraform apply terraform.plan"
    rates_elb_ip = sh(returnStdout: true, script: "terraform output rates_dns_name").trim()
    return rates_elb_dns
}
