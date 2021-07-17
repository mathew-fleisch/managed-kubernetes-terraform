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
            # worker_groups = map(
            #     object({
            #         name                  = string
            #         instance_type         = string
            #         asg_min_size          = int
            #         asg_max_size          = int
            #         asg_desired_capacity  = int
            #         additional_security_group_ids = list(string)
            #     })
            # )
variable "cluster" {
    type = map(
        object({
            name                  = string
            profile               = string
            region                = string
            kubernetes_version    = string

        })
    )
}