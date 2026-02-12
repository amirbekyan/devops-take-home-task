terraform {
  backend "remote" {
    hostname     = "devops-task.scalr.io"
    organization = "env-d3vop5T4sk0r9"

    workspaces {
      name = "devops-task"
    }
  }
}
