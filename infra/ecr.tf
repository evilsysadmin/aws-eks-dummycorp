# Usar recursos nativos de AWS en lugar del módulo que está causando problemas
resource "aws_ecr_repository" "repositories" {
  for_each = toset(local.repositories)
  
  name                 = each.value
  image_tag_mutability = "MUTABLE"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = local.common_tags
}

resource "aws_ecr_lifecycle_policy" "lifecycle_policies" {
  for_each = toset(local.repositories)
  
  repository = aws_ecr_repository.repositories[each.value].name
  policy     = local.lifecycle_policy
}

output "repository_urls" {
  value = {
    for repo_name in local.repositories : 
    repo_name => aws_ecr_repository.repositories[repo_name].repository_url
  }
}
