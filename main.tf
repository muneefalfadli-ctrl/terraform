resource "aws_instance" "compute_01_cloud" {
  ami           = "ami-080e1f13689e07408"
  instance_type = var.instance_size
  key_name      = "liftandshift"

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
    command = "ansible-playbook -i ${aws_instance.compute_01_cloud.public_ip}, --private-key ./liftandshift.pem -u ubuntu migration.yaml"
  }
}
