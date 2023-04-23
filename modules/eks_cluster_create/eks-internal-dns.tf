resource "aws_route53_zone" "internal_dns" {
  name = var.internal_dns_hostzone

  tags = {
    Environment = var.environment
  }
  
  vpc {
    vpc_id = aws_vpc.eks.id
  }
  depends_on = [
    aws_vpc.eks
  ]
}