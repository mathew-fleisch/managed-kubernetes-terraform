# variable "cluster_name" {
#   type = string
# }
# variable "profile" {
#   type = string
# }
# variable "region" {
#   type = string
# }
# variable "kubernetes_version" {
#   type = string
#   default = "1.20"
# }

variable "cluster" {
    type = object({
        name                  = string
        profile               = string
        region                = string
        kubernetes_version    = string
        worker_groups         = list(
          object({
              name                  = string
              instance_type         = string
              asg_min_size          = number
              asg_max_size          = number
              asg_desired_capacity  = number
          })
        )
    })
}