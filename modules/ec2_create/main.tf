resource "aws_instance" "ec2_template" {
  ami = var.ami_id == "" ? data.aws_ami.ubuntu.id : var.ami_id
  subnet_id = var.ec2_subnet_id
  key_name = var.ec2_key
  instance_type = var.instance_type
  vpc_security_group_ids = var.vpc_security_group_ids
  associate_public_ip_address = var.associate_public_ip_address
  monitoring = var.monitoring
  tags = {
    Name = var.instance_name
    Terraform = true
  }
  root_block_device {
    delete_on_termination = true
    encrypted = false
    volume_type = "gp2"
    volume_size = 10
   }
  # Pass the user data script from a file, if specified
  user_data = var.user_data != "" ? var.user_data : var.user_data_script
}

resource "aws_ebs_volume" "ebs_volume" {
  count = var.create_additional_volume == true ? 1:0
  availability_zone = var.ebs_add_availability_zone
  size              = var.add_ebs_volume_size
  tags = {
    Name = "${var.instance_name}-volume"
  }
}

resource "aws_volume_attachment" "ebs_attachment" {
  count = var.create_additional_volume == true ? 1:0
  device_name = "/dev/sdf"
  instance_id = aws_instance.ec2_template.id
  volume_id   = aws_ebs_volume.ebs_volume[0].id
}

# create static_ip and assign to ec2
resource "aws_eip" "ec2_public" {
  count = var.create_Elastic_IP == true ? 1:0
  instance = aws_instance.ec2_template.id
  tags = {
    Name = "${var.instance_name}-IP"
    Terraform = true
  }
}


