resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/18"
  tags = {
    Name = "devops14-2021-vpc"
  }


}
resource "aws_subnet" "my-subnet" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = "us-east-2a"

  tags = {
    Name = "devops14-2021-subnet1"
  }

}

resource "aws_route_table" "my-route-table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id

  }

  tags = {
    Name : "devops-rtb"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name : "devops14-2021-igw"
  }
}

resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id      = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my-route-table.id

}

/*
resource "aws_key_pair" "my-key" {
    key_name = "devops14_2021"
    public_key = file("${path.module}/my_public_key.txt")

}
*/
resource "aws_eip" "my_eip" {
  instance = aws_instance.devops-ec2.id
  vpc      = true
  tags = {
    Name  = "devops14_2021"
    Owner = "renzo"

  }
}

resource "aws_security_group" "devops14-2021" {
  name = "devops14_sg"
  description = "dynamic-sg"
  vpc_id = aws_vpc.my-vpc.id
  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = var.egress_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags = {
    Name = "devops14-2021-sg"
  }
}

resource "aws_instance" "devops-ec2" {
  ami                    = lookup(var.ami, "us-east-2")
  instance_type          = var.instance_type[0]
  subnet_id              = aws_subnet.my-subnet.id
  vpc_security_group_ids = [aws_security_group.devops14-2021.id]
  key_name               = aws_key_pair.my-key.key_name

  tags = {
    "Name" = element(var.tags, 0)
  }
}

resource "aws_key_pair" "my-key" {
  key_name   = "devops14_2021"
  public_key = file(var.public_key_location)
}

resource "aws_eip" "my-eip" {
  instance = aws_instance.devops-ec2.id
  vpc      = true
  tags = {
    Name  = "devops14_2021"
    Owner = "renzo"

  }
}

output "ec2_elastic-ip" {
  value = aws_eip.my-eip.public_ip
}