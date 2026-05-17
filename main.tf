resource "aws_instance" "compute_01_cloud" {
  ami           = "ami-080e1f13689e07408"
  instance_type = var.instance_size
  key_name      = "liftandshift"
iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

# Add this metadata options block to allow the Snap container to read the role
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Enforces IMDSv2
    http_put_response_hop_limit = 2          # Allows the token to pass through the container layer
  }



  # Connection, Provisioners, and Tags MUST be inside these braces
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/liftandshift.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "app_data.txt"
    destination = "/home/ubuntu/app_data.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Automation Complete' >> /home/ubuntu/log.txt",
      "cat /home/ubuntu/app_data.txt"
    ]
  }

  tags = {
    Name = var.instance_name
  }
} # <--- THIS is the only brace that should be here!

# NOW the Ansible trigger starts completely fresh

resource "null_resource" "ansible_trigger" {
  triggers = {
    instance_id = aws_instance.compute_01_cloud.id
  }

  provisioner "local-exec" {
    command = <<EOT
ansible-playbook -i ${aws_instance.compute_01_cloud.public_ip}, \
--private-key ./liftandshift.pem \
-u ubuntu shutdown.yaml \
-e "shutdown_time=${var.shutdown_time}"
EOT
  }
}


# 1. Create an IAM Role for the EC2 Instance
resource "aws_iam_role" "ssm_role" {
  name = "ec2-ssm-patching-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })
}

# 2. Attach the AWS-managed SSM policy to the role
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 3. Create the Instance Profile that EC2 consumes
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}

