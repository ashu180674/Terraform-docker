
# Terraform-docker
This project automates the deployment of a Dockerized application on an AWS EC2 instance using Terraform.i have used s3 as remote backend.
![Screenshot from 2024-04-26 13-18-36](https://github.com/ashu180674/terraform-docker/assets/105533911/10a3e02c-d627-4081-9733-80acd5fce4a8)

URL:  http://13.234.119.26:8081/api/v1


# Overview
The project provisions an EC2 instance on AWS, installs Docker, and deploys a Dockerized application. It utilizes Terraform for infrastructure provisioning and Docker for containerization.

# Folder Structure
- **main.tf**: Terraform configuration file defining AWS resources and provisioning steps.
- **backend.tf**: Remote-backend configuration to store state files in an S3 bucket.
- **variables.tf**: Contains input variables used in the Terraform configuration.
- **outputs.tf**: Defines output values to be displayed after Terraform execution.
- **security-group.tf**: Configuration for AWS security group.
- **application/**: Folder containing app.py,Dockerfile,requirements.txt files.

# Terraform Configuration (main.tf,backend.tf)
- *Defines the AWS provider with specified region and profile.*
- *Configures Terraform backend to store state files in an S3 bucket.*
- *Retrieves the latest Ubuntu AMI using aws_ami data source.*
- *Creates an EC2 instance with specified AMI, instance type, key pair, and security group.*
- *Configures EBS encryption using AWS KMS key and creates an encrypted EBS volume attached to the EC2 instance.*
- *Transfers application files (app.py, requirements.txt, Dockerfile) to the EC2 instance.*
- *Executes remote commands via SSH to install Docker, build Docker image, and run the containerized application.*
```bash

provider "aws" {
  region = var.region
  profile = "default"
}




data "aws_ami" "ubuntu_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
 
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
 
  owners = ["099720109477"] # Canonical official
}

resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ami.ubuntu_ami.id
  instance_type = var.instance_type
  associate_public_ip_address = true
  key_name = var.key_name
  security_groups = [aws_security_group.app_security_group.name]
}

resource "aws_kms_key" "ebs_encryption" {
  description         = "KMS key for EBS encryption"
  is_enabled          = true
  enable_key_rotation = true
}
 
resource "aws_ebs_encryption_by_default" "ebs_encryption" {
  enabled = true
}

resource "aws_ebs_volume" "encrypted_volume" {
  availability_zone = aws_instance.ec2_instance.availability_zone
  size              = 8
  encrypted         = true
  kms_key_id        = aws_kms_key.ebs_encryption.arn
}

resource "aws_volume_attachment" "ebs_attachment" {
  device_name = var.device_name
  volume_id   = aws_ebs_volume.encrypted_volume.id
  instance_id = aws_instance.ec2_instance.id
}

resource "null_resource" "app_block" {
  depends_on = [aws_volume_attachment.ebs_attachment]

  connection {
    type        = "ssh"
    user        = var.instance_user
    private_key = file(var.private_key_path)
    host = aws_instance.ec2_instance.public_ip
   }



provisioner "file" {
    source      = "/home/ashu/smallcase-assignment/application/app.py"
    destination = "/home/ubuntu/app.py"
  }

  provisioner "file" {
    source      = "/home/ashu/smallcase-assignment/application/requirements.txt"
    destination = "/home/ubuntu/requirements.txt"
  }

  provisioner "file" {
    source      = "/home/ashu/smallcase-assignment/application/Dockerfile"
    destination = "/home/ubuntu/Dockerfile"
  }


provisioner "remote-exec" {
inline = [
"export DEBIAN_FRONTEND=noninteractive",
"sudo apt-get update",
"sudo apt-get install -y docker.io",
"sudo usermod -aG docker ubuntu",
"sudo systemctl enable docker",
"sudo systemctl start docker",
"sudo docker build -t random_string_app . ",
"sudo docker run -d -p 8081:8081 random_string_app"
]
}
}


```
## Prerequisites

Before getting started, ensure the following prerequisites are met:

- **AWS CLI Installation**: Make sure the AWS Command Line Interface (CLI) is installed on your system. If not installed, follow the [official AWS CLI installation guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) for your operating system.

- **AWS CLI Configuration**: Configure the AWS CLI with the appropriate credentials and settings. Run `aws configure` command and provide your AWS Access Key ID, Secret Access Key, region, and default output format when prompted. Ensure the profile is configured correctly if using named profiles.

    ```bash
    aws configure
    ```


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

