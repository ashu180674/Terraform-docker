
# Terraform-docker
This project automates the deployment of a Dockerized application on an AWS EC2 instance using Terraform.

# Overview
The project provisions an EC2 instance on AWS, installs Docker, and deploys a Dockerized application. It utilizes Terraform for infrastructure provisioning and Docker for containerization.

# Folder Structure
- **main.tf**: Terraform configuration file defining AWS resources and provisioning steps.
- **variables.tf**: Contains input variables used in the Terraform configuration.
- **outputs.tf**: Defines output values to be displayed after Terraform execution.
- **security-group.tf**: Configuration for AWS security group.
- **application/**: Folder containing app.py,Dockerfile,requirements.txt files.

# Terraform Configuration (main.tf)
- Defines the AWS provider with specified region and profile.
- Configures Terraform backend to store state files in an S3 bucket.
- Retrieves the latest Ubuntu AMI using aws_ami data source.
- Creates an EC2 instance with specified AMI, instance type, key pair, and security group.
- Configures EBS encryption using AWS KMS key and creates an encrypted EBS volume attached to the EC2 instance.
- Transfers application files (app.py, requirements.txt, Dockerfile) to the EC2 instance.
- Executes remote commands via SSH to install Docker, build Docker image, and run the containerized application.
# Usage
- Clone the repository.
- Navigate to the project directory.
- Initialize Terraform: terraform init.
- Review and adjust variables in variables.tf.
- Apply the Terraform configuration: terraform apply.
- Access the deployed application via the public IP of the EC2 instance.

## License
This project is licensed under the MIT License.

## Credits
- AWS
- Docker
- Terraform

## Contact
For questions or support, contact project maintainer.

