pipeline {
  agent any
  
  environment {
    ARM_CLIENT_ID       = credentials('azure-client-id')
    ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
    ARM_TENANT_ID       = credentials('azure-tenant-id')
    ARM_USE_OIDC        = 'true'
    TF_IN_AUTOMATION    = 'true'
  }
  
  parameters {
    choice(
      name: 'ACTION',
      choices: ['plan', 'apply', 'destroy'],
      description: 'Terraform action to perform'
    )
    string(
      name: 'ENVIRONMENT',
      defaultValue: 'dev',
      description: 'Environment (dev/test/prod)'
    )
  }
  
  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'git rev-parse HEAD > .git/commit-id'
      }
    }
    
    stage('Terraform Init') {
      steps {
        dir('landing-zone') {
          sh '''
            terraform init \
              -backend-config="storage_account_name=sttfstate${ENVIRONMENT}" \
              -backend-config="key=${ENVIRONMENT}-landing-zone.tfstate"
          '''
        }
      }
    }
    
    stage('Terraform Validate') {
      steps {
        dir('landing-zone') {
          sh 'terraform validate'
        }
      }
    }
    
    stage('Terraform Plan') {
      steps {
        dir('landing-zone') {
          sh '''
            terraform plan \
              -var-file="environments/${ENVIRONMENT}.tfvars" \
              -out=${ENVIRONMENT}.tfplan
          '''
          
          // Archive plan for approval
          archiveArtifacts artifacts: "${ENVIRONMENT}.tfplan", fingerprint: true
        }
      }
    }
    
    stage('Approval') {
      when {
        expression { params.ACTION == 'apply' || params.ACTION == 'destroy' }
      }
      steps {
        script {
          def plan = readFile("landing-zone/${ENVIRONMENT}.tfplan")
          input message: "Review Terraform Plan", 
                parameters: [text(name: 'Plan', description: 'Terraform Plan', defaultValue: plan)]
        }
      }
    }
    
    stage('Terraform Apply') {
      when {
        expression { params.ACTION == 'apply' }
      }
      steps {
        dir('landing-zone') {
          sh 'terraform apply -auto-approve ${ENVIRONMENT}.tfplan'
        }
      }
    }
    
    stage('Terraform Destroy') {
      when {
        expression { params.ACTION == 'destroy' }
      }
      steps {
        dir('landing-zone') {
          sh '''
            terraform destroy \
              -var-file="environments/${ENVIRONMENT}.tfvars" \
              -auto-approve
          '''
        }
      }
    }
  }
  
  post {
    always {
      dir('landing-zone') {
        sh 'terraform show -no-color > terraform-output.txt || true'
        archiveArtifacts artifacts: 'terraform-output.txt', allowEmptyArchive: true
      }
      cleanWs()
    }
    success {
      echo 'Pipeline succeeded!'
    }
    failure {
      echo 'Pipeline failed!'
      // Add notification here (email, Slack, etc.)
    }
  }
}
