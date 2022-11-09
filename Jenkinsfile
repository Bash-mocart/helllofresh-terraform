pipeline {
    agent any

    parameters {
        string(name: 'environment', defaultValue: 'production', description: 'Workspace/environment file to use for deployment')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        booleanParam(name: 'destroy', defaultValue: false, description: 'Destroy Terraform build?')

    }


    stages {

        stage('Plan') {
            when {
                not {
                    equals expected: true, actual: params.destroy
                }
            }
            
            steps {
                dir('production') {
            
                sh 'terraform init -input=false'
                // sh 'terraform workspace select ${environment} || terraform workspace new ${environment}'

                sh "terraform plan -input=false"
                // sh 'terraform show -no-color tfplan > tfplan.txt'

            }
              
            }
        }
        stage('Approval') {
           when {
               not {
                   equals expected: true, actual: params.autoApprove
               }
               not {
                    equals expected: true, actual: params.destroy
                }
           }
           
                
            

           steps {
               script {
                    def plan = 'tfplan.txt'
                    input message: "Do you want to apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
               }
           }
       }

        stage('Apply') {
            when {
                not {
                    equals expected: true, actual: params.destroy
                }
            }
            
            steps {
                dir('infra/production') {
                withAWS(role:'jenkins', roleAccount:'438764419550', duration: 900, roleSessionName: 'jenkins-session'){
                sh "terraform apply -auto-approve"}
                     
                 }
            }
        }
        
        stage('Destroy') {
            when {
                equals expected: true, actual: params.destroy
            }
        
        steps {
            dir('infra/production') {
            sh 'terraform init -input=false'
           sh "terraform destroy --auto-approve" }
        }
    }

  }
}