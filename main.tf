resource "aws_s3_bucket" "muneef_test_bucket" {
  bucket = "muneef-cloud-lab-2026-test" # S3 bucket names must be unique globally
  
  tags = {
    Name        = "Muneef Lab"
    Environment = "Dev"
  }
}


# Find the Default VPC automatically
data "aws_vpc" "default" {
  default = true
}

# Create a Security Group for SSH access
resource "aws_security_group" "ssh_access" {
  name        = "lift_and_shift_sg"
  description = "Allow SSH from home"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In a real job, you'd use your specific Home IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# The EC2 Instance

resource "aws_instance" "compute_01_cloud" {
  ami           = "ami-080e1f13689e07408" # Ubuntu 22.04 LTS
  instance_type = "t3.micro"
  key_name      = "liftandshift"

  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  # 1. Connection settings for Terraform to use SSH
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/liftandshift.pem")
    host        = self.public_ip
  }

  # 2. Automatically "Lift" the file during creation
  provisioner "file" {
    source      = "app_data.txt"
    destination = "/home/ubuntu/app_data.txt"
  }

  # 3. Optional: Run a command to confirm it arrived
  provisioner "remote-exec" {
    inline = [
      "echo 'Automation Complete' >> /home/ubuntu/log.txt",
      "cat /home/ubuntu/app_data.txt"
    ]
  }

  tags = {
    Name = "Shifted-Compute-01"
  }
}
