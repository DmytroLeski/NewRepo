provider "aws" {
  region = "us-west-2"  
}

resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"  

  tags = {
    Name = "example-vpc"
  }
}

resource "aws_security_group" "example_sg" {
  name        = "example-sg"
  description = "Example security group"
  vpc_id      = aws_vpc.example_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "example-security-group"
  }
}

resource "aws_instance" "example_ec2_1" {
  ami           = "ami-xxxxxxxx"  
  instance_type = "t2.micro"      
  key_name      = "example-key"   

  vpc_security_group_ids = [aws_security_group.example_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y docker.io

    # Завантаження та запуск Prometheus stack
    sudo docker run -d -p 9090:9090 --name prometheus prom/prometheus

    # Завантаження та запуск Node-exporter
    sudo docker run -d -p 9100:9100 --name node-exporter prom/node-exporter

    # Завантаження та запуск Cadvizor-exporter
    sudo docker run -d -p 8080:8080 --name cadvisor-exporter google/cadvisor:latest
    EOF

  provisioner "remote-exec" {
    inline = [
      "sleep 30",  
      "curl http://localhost:9090",  
      "curl http://localhost:9100",  
      "curl http://localhost:8080",  
    ]
  }

  tags = {
    Name = "example-ec2-1"
  }
}

resource "aws_instance" "example_ec2_2" {
  ami           = "ami-xxxxxxxx"  
  instance_type = "t2.micro"      
  key_name      = "example-key"   

  vpc_security_group_ids = [aws_security_group.example_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y docker.io

    sudo docker run -d -p 9100:9100 --name node-exporter prom/node-exporter

    sudo docker run -d -p 8080:8080 --name cadvisor-exporter google/cadvisor:latest
    EOF

  provisioner "remote-exec" {
    inline = [
      "sleep 30",  
      "curl http://localhost:9100",  
      "curl http://localhost:8080", 
    ]
  }

  tags = {
    Name = "example-ec2-2"
  }
}