# Terraform & GCP => UiPath Orchestrator production environment
Steps to provision Orchestrator on AWS in ASG (Auto scaling group):
1. Install terraform  v1.0.2 (https://learn.hashicorp.com/terraform/getting-started/install.html).
2. Rename terraform-tfvars-template.tf to terraform.tfvars and then complete the file according to the variables.tf file (see inputs below). For Orchestrator hardware requirements and EC2 types check : https://aws.amazon.com/ec2/instance-types/  and https://orchestrator.uipath.com/docs/hardware-requirements-orchestrator.
3. Change directory to path of the Orchestrator plan (cd C:\path\to\orchestrator\plan).
4. Run : ` terraform init `
5. Run : ` terraform plan `
6. Check the plan of the resources to be deployed and type ` yes ` if you agree with the plan.
7. Wait 15-20 mins and enjoy! The password of the Orchestrator is the password used to ` orchestrator_password ` variable.

## Optional way to run the scripts using a plan file examples
#Terraform Plan with output file
terraform plan -out=C:\Users\axel.ramirez\Desktop\Uipath\AWS\TerraformCode\Infrastructure-master\AWS\Terraform\Orchestrator\multi-node\uipath.plan

#Apply the Plan to create
terraform apply "uipath.plan"

#Plan the destroy
#Terraform Plan with output file
terraform plan -destroy -out=C:\Users\axel.ramirez\Desktop\Uipath\AWS\TerraformCode\Infrastructure-master\AWS\Terraform\Orchestrator\multi-node\uipathdestroy.plan

#Apply the destroy plan
terraform apply "uipathdestroy.plan"


## Terraform version
Terraform v1.0.2

## Inputs
