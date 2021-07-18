# worker_additional_security_group_ids = list(string)

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