variable "project_name" {
  type    = string
  default = "belajar-kube-457207"
}

variable "region" {
  type    = string
  default = "asia-southeast1"
}

variable "zone" {
  type    = string
  default = "asia-southeast1-a"
}

variable "hostname" {
  type    = string
  default = "jenkins-server"
}

variable "ssh_keys" {
  type    = map(string)
  default = null
}
