provider "kubernetes" {
  # load_config_file = false
  host = data.aws_eks_cluster.myapp-cluster.endpoint
  token = data.aws_eks_cluster_auth.myapp-cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.myapp-cluster.certificate_authority.0.data)
}

data "aws_eks_cluster" "myapp-cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "myapp-cluster" {
  name = module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"
  cluster_name = "myapp-eks-cluster"
  cluster_version = "1.7"

  subnet_ids = module.myapp_vpc.private_subnets
  vpc_id = module.myapp_vpc.vpc_id

  tags ={
    environment = "development"
    application = "myapp"
  }


  self_managed_node_group_defaults = {
    instance_type                          = "t2.small"
    update_launch_template_default_version = true
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  self_managed_node_groups = {
    one = {
      name         = "mixed-1"
      max_size     = 5
      desired_size = 2

      use_mixed_instances_policy = true
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 0
          on_demand_percentage_above_base_capacity = 10
          spot_allocation_strategy                 = "capacity-optimized"
        }

        override = [
          {
            instance_type     = "t2.small"
            weighted_capacity = "2"
          },
          {
            instance_type     = "t2.medium"
            weighted_capacity = "1"
          },
        ]
      }
    }
  }
}