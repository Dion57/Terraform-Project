resource "aws_vpc" "mtc_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "new_pub_subnet" {
  vpc_id                  = aws_vpc.mtc_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "new_pub_subnet"
  }
}

resource "aws_internet_gateway" "new_igw" {
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "new_igw"
  }
}

resource "aws_route_table" "new_pub_route" {
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "new_pub_route"
  }
}

resource "aws_route" "new_route" {
  route_table_id         = aws_route_table.new_pub_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.new_igw.id
}

resource "aws_route_table_association" "new_pub_table_asso" {
  subnet_id      = aws_subnet.new_pub_subnet.id
  route_table_id = aws_route_table.new_pub_route.id
}

resource "aws_security_group" "new_secg" {
  name        = "new_secg"
  description = "new sec group"
  vpc_id      = aws_vpc.mtc_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "new_auth" {
  key_name   = "newkey"
  public_key = file("~/.ssh/newkey.pub")
}

resource "aws_instance" "dev_node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.new_auth.id
  vpc_security_group_ids = [aws_security_group.new_secg.id]
  subnet_id              = aws_subnet.new_pub_subnet.id
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = "10"
  }

  tags = {
    Name = "dev_node"
  }

  provisioner "local-exec" {
    command = templatefile("linux-ssh-config.tpl", {
      hostname = self.public_ip,
      user = "ubuntu",
      identityfile = "~/.ssh/newkey.pem"
    })
    interpreter = ["bash", "-c"]
  }


}