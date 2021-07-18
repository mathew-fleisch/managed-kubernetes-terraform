module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster.name
  cluster_version = var.cluster.kubernetes_version
  subnets         = aws_subnet.private_subnet.*.id

  tags = {
    ClusterName = var.cluster.name
    mks = "true"    
  }

  vpc_id = aws_vpc.vpc.id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = var.cluster.worker_groups
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}