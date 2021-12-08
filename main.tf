

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.68.0"
    }
  }
  
   backend "remote" {
    organization = "rakarthik"

    workspaces {
      name = "dev"
    }
  }
}


  
provider "aws" {
  # Configuration options
  region = "us-east-2"
}

locals {

	owner_name="karthikeyan"
}

output "PublicIP" {

	value=aws_instance.app_server.public_ip
}

data "aws_vpc" "main" {
  id = "vpc-67eb6b0c"
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      =  data.aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [data.aws_vpc.main.ipv6_cidr_block]
  }
  
    ingress {
    description      = "Open 443"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [data.aws_vpc.main.ipv6_cidr_block]
  }
  
    ingress {
    description      = "Open port 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [data.aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}


resource "aws_instance" "app_server" {
  ami           = "ami-002068ed284fb165b"
  instance_type = "t2.micro"
  key_name="${aws_key_pair.deployer.key_name}"
  #security_groups="${aws_security_group.allow_tls.name}"
  vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
  user_data = "${file("installweb.sh")}"  

  provisioner "remote-exec" {
    inline = ["sudo chown ec2-user /var/www/html"]
      
    connection {
    	type     = "ssh"
        user     = "ec2-user"
    	private_key = "${file("id_rsa")}"
    	host     = aws_instance.app_server.public_ip
  	}
  }


  
  

  tags = {    
    Name = "KavinAppServer"
    Owner = "Owner:${local.owner_name}"
    
  }
}

resource "null_resource" "copyfile" {

    connection {
    	type     = "ssh"
        user     = "ec2-user"
    	private_key = "${file("id_rsa")}"
    	host     = aws_instance.app_server.public_ip
  }
  
  provisioner "file" {
    source      = "helloworld.html"
    destination = "/var/www/html/helloworld.html"   

  }
  
  depends_on = [aws_instance.app_server]
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCjtqEP+R9N3KRYPG5ORpZcj0/vTwebxPVZPFdRl+6TVQMLc85gtNIuqY6n6Xg2/7b6l+urtHFEs5EOCCnhdmlEuKaycC7WDLDV36QOiIGAjRcwQguJWxD5X1PeG3fpZIUFVZvKKsu2Zbxy3ga1MLo71daznep1NlGMEnnIK/xb1jJZXOY1jPpmCeZCSwhMMd71PMR9NzNl5aWZcvGmWKt+zq7VYmPXjr8vtfe9+J/5G2WpI1dwOS/HjHowIEnE0BykMLdBcTlEgpKp2NWqQDY59F9d/iOi1oqe7V97q4JPM11sV1R4c/8so7aipFlFWc9URztHBqBVuoI64N/9lOuuYyn7oG+uMRTV+vd7ahyYuYIHJLyQM2EKUCtoN3lXbPDENtvv535s7PPi3duooodjGrjlAT7RVUhyAI9YbXoANn/ZtfXqLJa8TITaiuVel+6gWaW9u3lOiKnxpqDY4UlXtBWRX0SgkU50YAsb6HH/On/+6IHhb6pK3oJuucasmB8= karthikeyan@karthikeyan-Gateway-NE46Rs"
}



