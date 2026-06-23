locals {
  
  common_tags = {
     Project = var.project
     Environment = var.environment
     Name = local.common_name
     Terraform = "true"
  }
  common_name = "${var.project}-${var.environment}" 
  az_names = slice(data.aws_availability_zones.available.names, 0,2) # here we are using slice function to select first 2 names in list                                                                                                                                                                          
}