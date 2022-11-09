provider "aws" {
  region = "ap-southeast-1"
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.4.0"

    
    
    # kubernetes = {
    #   source = "hashicorp/kubernetes"
    #   version     = "~>2.7.1"
    # }

    # local = {
    #   source = "hashicorp/local"
    #   version = "~>2.1.0"
    # }
    }
  }
  # using terraform cloud as backend 
  backend "remote" {
    #          The name of your Terraform Cloud organization.
    organization = "hellofresh-infra"
    #
    #         # The name of the Terraform Cloud workspace to store Terraform state files in.
    workspaces {
      name = "production"
    }
  }
}

module "eks" {
  source                  = "../terraform/module/eks/"
  db_username             = var.db_username
  db_password             = var.db_password
  az-a                    = "ap-southeast-1a"
  az-b                    = "ap-southeast-1b"
  eks_node_group_iam_role = "eks_node_group_role_prod"
  eks_cluster_role        = "eks_cluster_role_prod"
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}


output "postgresdns" {
  value     = module.eks.dns
  sensitive = true
}


provider "kubernetes" {
  host                   = module.eks.endpoint
  cluster_ca_certificate = base64decode(module.eks.kubeconfig-certificate-authority-data )
  # token                  = data.aws_eks_cluster_auth.cluster.token
  # load_config_file       = false
  exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.name]
      command     = "aws"
    }
}


provider "helm" {
  kubernetes {
    host = module.eks.endpoint
    cluster_ca_certificate = base64decode(module.eks.kubeconfig-certificate-authority-data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name",  module.eks.name]
      command     = "aws"
    }
  # load_config_file       = false
  }
}


resource "kubernetes_namespace" "hf-namespace-dev" {
  metadata {
    name = "dev"
  }
}

resource "kubernetes_namespace" "hf-namespace-prod" {
  metadata {
    name = "master"
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress-controller"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
}
