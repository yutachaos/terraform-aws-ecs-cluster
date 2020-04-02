variable "cluster_name" {
  description = "Cluster name."
}
variable "tags" {
  description = "Tags."
  type        = map(string)
}
variable "trusted_cidr_blocks" {
  description = "Trusted subnets e.g. with ALB and bastion host."
  type        = list(string)
  default     = [""]
}
variable "instance_types" {
  description = "ECS node instance types. Maps of pairs like `type = weight`. Where weight gives the instance type a proportional weight to other instance types."
  type        = map(any)
  default = {
    "t3a.small" = 2
  }
}
data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}
variable "spot" {
  description = "Choose should we use spot instances or on-demand to poulate ECS cluster."
  type        = bool
  default     = false
}
variable "security_group_ids" {
  description = "Additional security group IDs. Default security group would be merged with the provided list."
  default     = []
}
variable "subnets_ids" {
  description = "IDs of subnets. Use subnets from various availability zones to make the cluster more reliable."
}
variable "target_capacity" {
  description = "The target utilization for the cluster. A number between 1 and 100."
  default     = "90"
}
data "aws_subnet" "default" {
  id = local.subnets_ids[0]
}

locals {
  vpc_id              = data.aws_subnet.default.vpc_id
  subnets_ids         = var.subnets_ids
  name                = replace(var.cluster_name, " ", "_")
  trusted_cidr_blocks = var.trusted_cidr_blocks
  instance_types      = var.instance_types
  sg_ids              = distinct(concat(var.security_group_ids, [aws_security_group.ecs_nodes.id]))
  ami_id              = data.aws_ssm_parameter.ecs_ami.value
  spot                = var.spot == true ? 100 : 0
  target_capacity     = var.target_capacity

  tags = merge({
    Name   = var.cluster_name,
    Module = "ECS Cluster"
  }, var.tags)
}