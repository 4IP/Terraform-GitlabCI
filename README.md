# Terraform-GitlabCI
HCL (Terraform) script and GitlabCI yaml

# 1. Terraform
* <p>The HCL script only for AWS, for use this script first setup awscli. This link for download awscli:</p>

    * <https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html>

* Then install terraform
* Clone this repo, then enter directory Terraform and run command:

    * `terraform init`
    * `terraform plan`
    * `terraform apply`

# 2. Gitlab CI
* <p>The example script to build dockerfile with gitlabci, then push into gitlab registry. The script is simple to deploy nginx into docker and run</p>

    *note: but this script still won't running into docker if one machine with gitlab-runner, i can't try to test this script because i have a work deadlines. I mean can not test separate with gitlab-runner and then target machine(docker)*