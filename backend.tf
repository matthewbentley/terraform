terraform {
  backend "remote" {
    organization = "bentley"

    workspaces {
      name = "terraform"
    }
  }
}
