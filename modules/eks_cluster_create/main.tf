resource "aws_key_pair" "admin" {
  key_name   = "${var.environment}-admin-key"
  public_key = var.public_key
}

############################################################
module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "19.10.0"
  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  vpc_id                         = aws_vpc.eks.id
  subnet_ids                     = aws_subnet.eks_private_subnet[*].id
  create_iam_role                = false
  iam_role_arn                   = aws_iam_role.eks_cluster.arn
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  #  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  ################################################################
  ################ CLUSTER IAM FOR AWS_AUTH ######################
  manage_aws_auth_configmap = true

  aws_auth_roles = [
      {
      rolearn  = aws_iam_role.eks_role.arn
      username = aws_iam_role.eks_role.name
      groups   = ["system:masters"]
    }
  ]           

  aws_auth_users = [
    {
      userarn  = aws_iam_user.eks_user.arn
      username = aws_iam_user.eks_user.name
      groups   = ["system:masters"]
    }
  ]

  #################################################################
  ####################   LOGGING   ################################
  create_cloudwatch_log_group = true                       # default
  cluster_enabled_log_types   = ["audit", "authenticator"] # default is [ "audit", "api", "authenticator" ]

  #################################################################
  #################### CLUSTER SECURITY GROUP  ####################
  create_cluster_security_group = true #masternode communicate with worker nodes
  cluster_security_group_name   = "${var.cluster_name}-clusterSG"
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_source_security_group_id = {
      description              = "allow ssh from private range (vpc-vpn)"
      protocol                 = "tcp"
      from_port                = 22
      to_port                  = 22
      type                     = "ingress"
      cidr_blocks = ["10.0.0.0/8","172.16.0.0/12","192.168.0.0/16"]
    }
  }
  ###################################################################
  #################### WORKER NODES #################################
  #there is option create in eks module, and also can create in eks_managed_node_group, for example here we can create SG in eks module or create inside eks_manage_node

  create_node_security_group = true
  node_security_group_name   = "${var.cluster_name}-workernodesSG"

  # Define default settings for EKS managed node groups
  eks_managed_node_group_defaults = {
    ami_type          = "AL2_x86_64"
    key_name          = aws_key_pair.admin.key_name
    enable_monitoring = true
    create_iam_role   = false
    iam_role_arn      = aws_iam_role.eks_node.arn
    capacity_type     = "SPOT"
    min_size          = 0
    desired_size      = 1
    max_size          = 2
    platform          = "linux"
    depends_on = [
      aws_key_pair.admin,
      aws_subnet.eks_private_subnet
    ]
  }

  eks_managed_node_groups = {
    datastore-workers = {
      name          = "${var.cluster_name}-data-worker"
      instance_types= ["${var.workergroup.instance_type}"]
      disk_size     = var.workergroup.disk_size
      capacity_type = var.workergroup.capacity_type
      desired_size  = var.workergroup.desired_size
      taints = {
        dedicated = {
          key    = "node-role"
          value  = "datastore"
          effect = "NO_SCHEDULE"
        }
      }       
    }
    apps-workers = {
      name          = "${var.cluster_name}-apps-worker"
      instance_types = ["${var.workergroup.instance_type}"]
      disk_size     = var.workergroup.disk_size
      capacity_type = var.workergroup.capacity_type
      desired_size  = var.workergroup.desired_size
    }
  }

  tags = {
    Environment = var.environment #tag for all resource
    Attachment  = "${var.cluster_name}"
    Terraform   = true
  }

}
