



locals {

	owner_name="karthikeyan"
}

resource "aws_instance" "demowebserver" {
  ami           = "ami-002068ed284fb165b"
  instance_type = "t2.micro"

  vpc_security_group_ids = ["sg-0802d4b2ecaa6107d"]
  #user_data = "${abspath(path.module)}/installweb.sh"
  user_data = "${file("${abspath(path.module)}/installweb.sh")}"
  #user_data = "${file("installweb.sh")}"  
  tags = {    
    Name = "DemoWebServer"
    Owner = "Owner:${local.owner_name}"
    
  }
}

