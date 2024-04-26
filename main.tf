provider "aws" {
  region = var.region
  profile = "default"
}


terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket         = "terraform-backend-test12"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
  }
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
  depends_on = [aws_ebs_volume.encrypted_volume]
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

