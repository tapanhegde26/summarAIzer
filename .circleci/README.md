# Build Pipeline

The build pipeline uses CircleCI to run Terraform validate, format and plan commands on non-main branches. On the main branch Terraform plan and apply are used with a hold step before Terraform apply to allow for manual review and deployment. 

The build pipeline jobs and workflows are in the [config.yml](./config.yml) file. Tasks common to multiple jobs (checkout, aws-cli/setup and terraform init) are in the commands section listed under terraform-setup. Each job includes terraform-setup to ensure the job environment has all of the required setup needed