
variable "region" {
  description = "The AWS region in which to launch the resources."
  default     = "ap-south-1"
}

variable "security_group_name" {
  description = "The name of the security group."
  default     = "app_security_group"
}

variable "instance_type" {
  description = "The instance type to launch."
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the key pair to use for SSH access."
  default     = "ashu1"
}

variable "device_name" {
  description = "The device name for the attached EBS volume."
  default     = "/dev/sdf"
}

variable "instance_user" {
  description = "The username for connecting to the instance via SSH."
  default     = "ubuntu"
}

variable "private_key_path" {
  description = "The path to the private key file for SSH access."
  default = "/home/ashu/Downloads/ashu1.pem"
}

