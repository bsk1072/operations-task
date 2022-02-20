# <span style="color:blue"> <em>Table of Contents</em> </span>

1. [ Rates App environment automation using Terraform. ](#ratesappenvironmentautomationusingTerraform)
2. [About the Project. ](#abouttheproject)
3. [ Requirements. ](#Requirements)
4. [ Code structure. ](#Codestructure)
5. [ Manual Execution Process](#ManualExecution)
6. [Automatic Execution Process](#AutoExecution)
7. [ Execution guide. ](#Executionguide)
8. [ Test the results. ](#Testtheresults)


<a name="ratesappenvironmentautomationusingTerraform"></a>
## 1. Rates App environment automation using Terraform

This repository contains the terraform modules for the rates python app environment provisioning on [Amazon Web Services (AWS)](https://aws.amazon.com/console/).

- Architecture model diagram,
   ![Rates-Architecture](http)

<a name="abouttheproject"></a>
## 2. About the project

The project is developed in a very generic model where we have to pass variables to the module
| Module Name      | location | What does it do     |
| :---        |    :----:   |          ---: |
| rates_infra      | resources/rates_infra       | Provisions rates environment on AWS - ECS, RDS  |


<a name="Requirements"></a>
## 3. Requirements

1. You must have **terraform** => 1.1.6 installed on your Linux Box.
   - Please install terraform client if not already installed by using below commands,
     - curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
     - sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
     - sudo apt-get update && sudo apt-get install terraform
2. You must have a Amazon Webservice Account (AWS) account.
   - Please follow the instructions to [Create AWS account](https://portal.aws.amazon.com/billing/signup?nc2=h_ct&src=header_signup&redirect_url=https%3A%2F%2Faws.amazon.com%2Fregistration-confirmation#/start).
   - Generally, AWS provides a free tier acccess with 1 year validity for first time. To Sign up users refer to [AWS free tier](https://aws.amazon.com/free/).
<a name="step-3.3"></a>
3. You must have a credentials file from your AWS account using [security credentials in the AWS Console](https://console.aws.amazon.com/iam/home?region=eu-west-1#/security_credentials). **⚠ REQUIRED:**  <span style="color:red">  You must sign in to access this page </span>
   - This Above link provides you options to download the credentials excell Format.
   - Please note the credentials that need to be set in the credentials file inside the home location.
   - Now, Copy the content from inside the aws credentials file and paste it inside credentials.json file you will find in the root location of this project.
   - This will set your credentials ready to authenticate to the GCP account via API calls.
4. Additionally, we need latest **ansible** server to run a small playbook which will automate the sql script executions into the psql server once environment is set.
5. This code is written in Terraform 1.1.6 environment.

<a name="Codestructure"></a>
## 4. Code structure:

### A typical top-level directory layout

    .
    ├── db                                                  # db scripts to be used for psql database
    ├── rates                                               # rates folder containers the python application
        └── config.py                                       # DB configurations for rates app
        └── rates.py                                        # rates app to fetch data from db (psql)
        └── wsgi.py                                         # Interface between web servers and web apps for python which will call rates app
    ├── resources                                           # Source functions for configurations. Actual backend logics (backend logicals modules)
        └── policies                                        # Contains IAM policies for ecs, rds and loadbalancer
            └── ecs-instance-role-policy.json               # ecs policy allowing access to different services. [look at this](resources/policies/ecs-instance-role-policy.json). Will be interally inside resources for configuration
            └── ecs-role.json                               # Contains the role for ecs, ec2. [look at this](resources/policies/ecs-role.json). Will be interally inside resources for configuration
            └── ecs-service-role-policy.json                # Contains policies to allow load balancers. [look at this](resources/policies/ecs-service-role-policy.json). Will be interally inside resources for configuration
        └── rates_infra                                     # This directory is a module with all set of configurations for provisioning the environment.
            └── iam.tf                                      # This will created iam policies for ecs and will use the set of polocies from the policies directory.
            └── keypair.tf                                  # This will create a key-pair in AWS for the ecs instance. Helps to ssh inside the instance.
            └── network.tf                                  # This will setup an entire network service usefull for rates app. Setting vpc for ecs instances along with availiability zones.
            └── securitygroups.tf                           # Very important, which sets the ports to be allowed from remote, locally and service wise. We are setting limited access to out infra instances
            └── loadbalancer.tf                             # This will set up a load balancer as a best practice for ecs to run applications.
            └── auto_scaling.tf                             # This configurations in AWS allows ecs cluster to manage the clusters.
            └── logs.tf  # We are tracking the logs for ecs cluster to investigate incase of any challenges with cluster.
            └── rds.tf  # This contains the resources to setup rds instances and feed data into it.
            └── ecs.tf  # This is the resources for setting the cluster with the docker image form registry.
            └── outputs.tf                                  # A single output is defined at this point to fetch the elb dns name.
            └── variables.tf                                # Contains declarations of variables used across the resources.
            └── provider.tf                                 # Contains the AWS regions. This can be set from root level too.
       └── templates  # ecs step definitions template to launch the docker images.
            └── rates_app.json.tpl                          # Step definitions for the ecs cluster.
    ├── main.tf                                             # This will call the rates-app modules with set of variables to pass it dynamically.
    ├── config.tf                                           # Storing state file remotely is a good practice. we are using S3 backed to store our statefiles.
    ├── playbook.yml                                        # Ansible playbook we are using to dump the sql file once the rds is provisioned.
    ├── Dockerfile                                          # A Dockerfile is a step by step instructions for building a docker image. We use this for auto build of pythong app.
    ├── Jenkinsfile                                         # A CICD file which orchastrates the actions to test the application in a conditional manner.
    ├── development.tfvars                                  # Development environment variables to be declared inside this file. (I did not provide the actual tfvars as it contains account details and sensitive data)
    ├── outputs.tf                                          # Contains outputs from the resources created in main.tf
    ├── provider.tf                                         # Used to configure your AWS module version.
    ├── README.md                                           # Assignment details
    ├── terraform-README.md                                 # Technical level explanation on the project
    └── variables.tf                                        # Contains declarations of variables with default used for main.tf

<a name="ManualExecution"></a>
## 5. Manual Execution Steps

Once the Changes are done. Developer needs to build the docker images and push the images to the Docker registry (Currently, ECR is configured).

Steps to build the latest app for execution,

- #### We must login to the AWS account before any actions using the below command,
    - aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin [AWS Account ID].dkr.ecr.eu-west-1.amazonaws.com
    - **⚠ WARNING:** <span style="color:red"> This command will ask the credentials for the first time login to authenticate the aws account.</span>
- #### Build a Docker image using Dockerfile in the root directory. Use below commands to build it,
    - docker build -t [AWS Account ID].dkr.ecr.eu-west-1.amazonaws.com/rates-ecr:latest .
- #### Now the image should be deployed to the Amazon Container Register using the below command,
    - docker push [AWS Account ID].dkr.ecr.eu-west-1.amazonaws.com/rates-ecr:latest
- #### Once the docker image is pushed into the ecr, its time to trigger the terraform code to provision the environment for along with code deployment and database execution.
    - terraform apply --var-file=development.tfvars
    - **⚠ WARNING:** <span style="color:red"> Please do update the development.tfvars file before execution.</span>
- #### To destroy the environment, please run the below command,
    - terraform destroy --var-file=development.tfvars
    - **⚠ WARNING:** <span style="color:red"> Please do update the development.tfvars file before execution.</span>


<a name="AutoExecution"></a>
## 6. Automatic Execution

This is a complete CICD job which need to explicit inputs. Once the developer is done with the script changes, he can commit the code to the repository. The pipeline will be executed with all configurations. Everything is configured inside Jenkinsfile.

Below figure shows the complete execution flow,
![Demo CICD for IaC- rates app](./images/CICD_IaC.JPG?raw=true)

Once the developer commits code to the repository, the pipeline in Jenkins gets triggered and executed the terraform execution. This pipeline is parameterized in a way, we can run categorically
- Apply- This will run the terraform execution and provision the infra
- Destroy - This parameter will destroy the infra provisioned earlier
- Image - This is will be used to create an image and push the image to ECR.


### Terraform Apply (default) - This will apply the infra on AWS, a full provision,
![Demo CICD for IaC- rates app](./images/PipelineExecution.JPG?raw=true)

### Executions logs can be seen like below,
![Demo CICD for IaC- rates app](./images/ApplyExecutionLogs.JPG?raw=true)

### Once execution is complete, pipeline will respond with the elb dns for access to the app,
![Demo CICD for IaC- rates app](./images/BrowserOutput.JPG?raw=true)

### Terraform Destroy - This Options will destroy the infra built on AWS using the previous state file,
![Demo CICD for IaC- rates app](./images/DestroyEnvPipeline.JPG?raw=true)

### Below Executions logs give your the number of resources terraform is destroyed,
![Demo CICD for IaC- rates app](./images/DestroyExecutionLogs.JPG?raw=true)

### Once execution is complete, the complete app will be destroyed,
![Demo CICD for IaC- rates app](./images/EnvironmentDestroy.JPG?raw=true)

**⚠ NOTE:** The Details are highlighted with yellow. 