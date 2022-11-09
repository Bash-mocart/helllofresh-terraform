output "dns" {
  value = aws_db_instance.postgres.address
  sensitive = true
}

output "endpoint" {
  value = aws_eks_cluster.eks.endpoint
  sensitive = true
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks.certificate_authority.0.data
  sensitive = true
}

output "identity-oidc-issuer" {
  value = "${aws_eks_cluster.eks.identity.0.oidc.0.issuer}"
  sensitive = true
}
 
output "name" {
  value = aws_eks_cluster.eks.name
  sensitive = true
}
 