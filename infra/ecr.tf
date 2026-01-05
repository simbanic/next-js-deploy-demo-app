resource "aws_ecr_repository" "nextjs" {
  name                 = "nextjs-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project     = "nextjs"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
