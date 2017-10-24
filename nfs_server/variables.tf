variable "nfs_name" {
    default = "test"
}

variable "nfs_size" {
    default = 1
}

variable "region" {
    default = "RegionOne"
}

variable "image" {
    default = "Ubuntu 16.04"
    description = "nova image-list : Name"
}

variable "flavor" {
    default = "m1.small"
    description = "nova flavor-list : Name"
}

variable "ssh_key_file" {
    default = "~/.ssh/id_rsa"
    description = "Path to pub key (assumes it ends with .pub)"
}

variable "ssh_user_name" {
    default = "ubuntu"
    description = "Image specific user"
}

variable "external_gateway" {
    default = "bef0fe11-1646-4826-9776-3afdf95e53b9"
    description = "nova net-list : Id (network with public interfaces)"
}

variable "pool" {
    default = "ext-net"
    description = "Network pool for assigning floating_ips"
}
