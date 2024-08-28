# Terraform-VPC

Hello Guys,
    This is my First terraform Project Launching an entire VPC 
         1) VPC
         2) PUBLIC AND PRIVATE SUBNET
         3) INTERNET GATEWAY
         4) ROUTE TABLE
         5) ROUTE TABLE ASSOCIATION
         6) ROUTING TO THE INTERNET GATEWAY FROM SUBNETS
         7) LAUNCHING AN EC2 INSTANCES IN BOTH SUBNET
         8) TERRAFORM COMMANDS

    sudo snap install aws_cli --classic
    aws configure

    source .env
    In my terraform file there is variable.tf folder and secret keys has been alloacted in the .env file 
