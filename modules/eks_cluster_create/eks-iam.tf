
#######################################################################################
####################### USER/ROLE AWS_EKS_AUTH ########################################

resource "aws_iam_user" "eks_user" {
  name = "${var.cluster_name}-${var.aws_auth_user}"
  tags = {
    "Attachment" = "${var.cluster_name}"
  }
}

# create iam_role, mapping to aws_auth for eks cluster"
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "eks_role" {
  name = "${var.cluster_name}-${var.aws_auth_role}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = [ 
            "${data.aws_caller_identity.current.arn}", 
            "${aws_iam_user.eks_user.arn}"
          ]
        }
      }
    ]
  })
  tags = {
    "Attachment" = "${var.cluster_name}"
  }

  depends_on =[
    aws_iam_user.eks_user 
  ]
}

########################################################################################
############################## EKS_CLUSTER ROLES(EKS control plane)#####################


resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-cluster"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole"
        Effect : "Allow",
        Principal : {
          Service : "eks.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy" "KMS_policy" {
  name = "${var.cluster_name}-KMS-policy"
  role = aws_iam_role.eks_cluster.name

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "kms:*"
        ],
        Resource : "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster.name
}

##########################################################################################
########################### EKS_NODE ROLE ################################################

resource "aws_iam_role" "eks_node" {
  name = "${var.cluster_name}-node"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole"
        Effect : "Allow",
        Principal : {
          Service : "ec2.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}


resource "aws_iam_role_policy_attachment" "eks_node_AmazonS3ReadOnlyAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AutoScalingFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  role       = aws_iam_role.eks_node.name
}


resource "aws_iam_instance_profile" "eks_node" {
  name = "${var.cluster_name}-eks-node-profile"
  role = aws_iam_role.eks_node.name
}

#### role for external-dns route53 in eks #####################
resource "aws_iam_role_policy" "eks_external_dns" {
  name = "${var.cluster_name}-eks-external-route53dns"
  role = aws_iam_role.eks_node.name
  policy = jsonencode({ 
    Version : "2012-10-17", 
    Statement: [ 
      { 
        Effect : "Allow", 
        Action : [ 
          "route53:ChangeResourceRecordSets" 
        ], 
        Resource : [ 
          "arn:aws:route53:::hostedzone/*" 
        ] 
      }, 
      { 
        Effect : "Allow", 
        Action : [ 
          "route53:ListHostedZones", 
          "route53:ListResourceRecordSets" 
        ], 
        Resource : [ 
          "*" 
        ] 
      } 
    ] 
  })
}