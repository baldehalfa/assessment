# Creating vpc
resource "aws_vpc" "alpha-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Alpha"
  }
}

# Creating Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.alpha-vpc.id
}

# Creating Custom Route Table
resource "aws_route_table" "alpha-route-table" {
  vpc_id = aws_vpc.alpha-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Alpha"
  }
}

# Creating a Subnet 
resource "aws_subnet" "alpha-subnet" {
  vpc_id            = aws_vpc.alpha-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "Alpha"
  }
}

# Associating subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.alpha-subnet.id
  route_table_id = aws_route_table.alpha-route-table.id
}


# Creating security group
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.alpha-vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
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
    Name = "alpha-sg"
  }
}


# Creating a network interface
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.alpha-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}


# Creating elastic IP
resource "aws_eip" "alpha" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

output "server_public_ip" {
  value = aws_eip.alpha.public_ip
}

# Creating Ubuntu server and run docker 
resource "aws_instance" "web-server-instance" {
  ami               = "ami-055147723b7bca09a"
  instance_type     = "t2.micro"
  availability_zone = "ap-southeast-1a"
  key_name          = "alpha"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y

                # Install docker
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                echo \
                  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
                  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt-get update -y
                sudo apt-get --assume-yes install docker-ce docker-ce-cli containerd.io
                # Install docker compose
                echo "----------- Installing docker-compose ----------"
                sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                sudo chmod +x /usr/local/bin/docker-compose
                sudo curl \
                    -L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose \
                    -o /etc/bash_completion.d/docker-compose
                source ~/.bashrc
                echo "----------- DONE ----------"
                EOF

  tags = {
    Name = "alpha-server"
  }
}

output "server_private_ip" {
  value = aws_instance.web-server-instance.private_ip

}

output "server_id" {
  value = aws_instance.web-server-instance.id
}
