################ Security group ####################
resource "aws_security_group" "bastion" {
  name        = "bastion_host_sg"
  vpc_id= data.terraform_remote_state.vpc.outputs.vpc_id

  dynamic "ingress" {
    for_each = toset(var.ingress_port)
    content {
    description      = "allow access for bastion"
    from_port        = ingress.value
    to_port          = ingress.value
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion_host_sg"
    Terraform = true
  }
}

#####################################################
module "ec2-server" {
 source = "../../modules/ec2_create"
 instance_name = "bastion-host"
 ami_id = "ami-0d979355d03fa2522"
 ec2_subnet_id= data.terraform_remote_state.vpc.outputs.public_subnets[0]
 ec2_key = "devops-admin"
 instance_type = "t2.medium"
 vpc_security_group_ids = [aws_security_group.bastion.id]
 associate_public_ip_address = true
 monitoring = "true"
 #user_data_script= data.template_file.user_data.rendered
 user_data_script=templatefile("${path.module}/user-data.tpl", {
    namexyz = var.namexyz
    secret = data.aws_ssm_parameter.user_database.value
  })
 depends_on  = [
    aws_security_group.bastion
    ]
}