provider "aws" {
  region     = "us-east-2"
  access_key ="AKIARDDGK2ZKNSO2JLN5"
  secret_key ="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"  
}
#####################################################
#Creating Production VPC with CIDR: 10.0.0.0/16
resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16" 
    tags = {
        Name = "Prod-VPC"
    }
}
output "vpcid" {
  value = aws_vpc.vpc.id
}
#######################################################
#Creating Public Subnet with CIDR: 10.0.0.0/24
resource "aws_subnet" "production_public_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name        = "PROD-PUBLIC-BASTION-SUB-AZ1"
  }
}
output "public_subnetid" {
  value = aws_subnet.production_public_subnet.id
}
#######################################################
#Creating Private Subnet with CIDR: 10.0.1.0/24
resource "aws_subnet" "prodution_private_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2b"
  tags = {
    Name        = "PROD-PRIVATE-WEB-SUB-AZ1"
  }
}
output "private_subnetid" {
  value = aws_subnet.prodution_private_subnet.id
}
#######################################################
#Creating Private Subnet with CIDR: 10.0.2.0/24
resource "aws_subnet" "prodution_private_subnet2" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2c"
  tags = {
    Name        = "PROD-PRIVATE-APP-SUB-AZ1"
  }
}
output "private_subnet2id" {
  value = aws_subnet.prodution_private_subnet2.id
}

#######################################################
#Creating IGW and attaching for Prod VPC 
resource "aws_internet_gateway" "prod_igw" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags = {
        Name = "prod-igw"
    }
}
output "internet_gateway_id" {
  value = aws_internet_gateway.prod_igw.id
}
###############################################################
#Adding Route table and IGW
resource "aws_route_table" "prod_public_rt1" {
    vpc_id = "${aws_vpc.vpc.id}"  
    route {
        cidr_block = "0.0.0.0/0"         
        gateway_id = "${aws_internet_gateway.prod_igw.id}" 
    }
    tags = {
        Name = "prod-public-rt"
    }
}
output "Prod_Public_RT_id" {
  value = aws_route_table.prod_public_rt1.id
}
############################################################
#Adding Route table and IGW
resource "aws_route_table" "prod_public2_rt" {
    vpc_id = "${aws_vpc.vpc.id}"  
    route {
        cidr_block = "0.0.0.0/0"         
        gateway_id = "${aws_internet_gateway.prod_igw.id}" 
    }
    tags = {
        Name = "prod-public-rt"
    }
}
output "Prod_Public_RT_id2" {
  value = aws_route_table.prod_public2_rt.id
}
#######################################################
#Adding public subnet to public route table
resource "aws_route_table_association" "prod-public-routetable"{
    subnet_id = "${aws_subnet.production_public_subnet.id}"
    route_table_id = "${aws_route_table.prod_public2_rt.id}"
}
###############################################

#Creating an 1st-EIP
resource "aws_eip" "production_1stnat_eip" {
  vpc = true
  tags = {
      Name = "production_1stnat_eip"
  }
}
output "production_1stnat_eip" {
  value = aws_eip.production_1stnat_eip.id
}
###############################################

#Creating an 2nd-EIP
resource "aws_eip" "production_2ndnat_eip" {
  vpc = true
  tags = {
      Name = "production_2ndnat_eip"
  }
}
output "production_2ndnat_eip" {
  value = aws_eip.production_1stnat_eip.id
}
###################################################################
#Creating 1st-NatGateway for Production VPC
resource "aws_nat_gateway" "production_1stnatgateway"{
   allocation_id= "${aws_eip.production_1stnat_eip.id}"
   subnet_id = "${aws_subnet.production_public_subnet.id}"
    tags = {
      Name = "Production 1stNatgateway"
          }
}
output "production_1stnatgateway_id" {
  value = aws_nat_gateway.production_1stnatgateway.id
}

#Creating 2nd-NatGateway for Production VPC
resource "aws_nat_gateway" "production_2ndnatgateway"{
   allocation_id= "${aws_eip.production_2ndnat_eip.id}"
   subnet_id = "${aws_subnet.production_public_subnet.id}"
    tags = {
      Name = "Production 2ndNatgateway"
          }
}
output "production_2ndnatgateway_id" {
  value = aws_nat_gateway.production_2ndnatgateway.id
}
######################################################################################







