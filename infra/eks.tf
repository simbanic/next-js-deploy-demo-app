# --------------------
# EKS Cluster
# --------------------
resource "aws_eks_cluster" "this" {
  name     = "demo-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  vpc_config {
    subnet_ids              = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]
    endpoint_private_access = true
    endpoint_public_access  = true
  }
}

# --------------------
# Node Group (ARM / PRIVATE)
# --------------------
resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "default-ng"
  node_role_arn   = aws_iam_role.eks_node.arn

  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr
  ]

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  instance_types = ["t4g.medium"]
  ami_type       = "AL2023_ARM_64_STANDARD"
}
