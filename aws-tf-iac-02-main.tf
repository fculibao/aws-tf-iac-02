provider "aws" {
    region = "us-east-1"    
}

## 1. Create a VPC
resource "aws_vpc" "web02-prod-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.tag_name
  }
}

## 2. Create Internet Gateway
resource "aws_internet_gateway" "web02-prod-gw" {
  vpc_id = aws_vpc.web02-prod-vpc.id

  tags = {
    Name = var.tag_name
  }
}
## 3. Create Custom Route Table
resource "aws_route_table" "web02-prod-route-table" {
  vpc_id = aws_vpc.web02-prod-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.web02-prod-gw.id
  }
  
  route {
      ipv6_cidr_block        = "::/0"
      gateway_id = aws_internet_gateway.web02-prod-gw.id
    }

  tags = {
    Name = var.tag_name
  }
}

## 4. Create a Subnet
resource "aws_subnet" "web02-prod-subnet" {
  vpc_id     = aws_vpc.web02-prod-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = var.tag_name
  }
}

## 5. Associate Subnet with the Route Teble
resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.web02-prod-subnet.id
  route_table_id = aws_route_table.web02-prod-route-table.id

}


## 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "web02-prod-allow-http-https-traffic" {
  name        = "allow_http_https"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.web02-prod-vpc.id

  ingress {
      description      = "HTTPS from VPC"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
      description      = "HTTP from VPC"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.tag_name
  }
}


## 7. Create a Network Interface with an IP in the Subnet that was created in Step 4
resource "aws_network_interface" "web02-prod-net-server-nic" {
  subnet_id       = aws_subnet.web02-prod-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.web02-prod-allow-http-https-traffic.id]

  tags = {
    Name = var.tag_name
  }
}

## 8. Assigh an Elastic IP to the Network Interface created in Step 7
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web02-prod-net-server-nic.id
  associate_with_private_ip = "10.0.1.50"

  tags = {
    Name = var.tag_name
  }
}


## 9. Create an Ubuntu Server and Install/Apache2
 resource "aws_instance" "web02-prod-server-instance" {
   ami               = var.ami_id
   instance_type     = var.instance_type
   #availability_zone = "us-east-1d"
   key_name          = var.key_name
   network_interface {
     device_index         = 0
     network_interface_id = aws_network_interface.web02-prod-net-server-nic.id
   }
   #Options
   #user_data = file("${path.module}/files/api-data.sh")
   #and inside the api-data.sh put all the commands you want to run on the instance
   user_data = "${file("aws-tf-iac-02-api-data.sh")}"
   tags = {
     Name = var.tag_name
   }
 }
