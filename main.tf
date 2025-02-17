### Provider

provider "aws" {
  profile = var.aws_profile
}


### Declare Availability Zones Data

data "aws_availability_zones" "available" {
  state = "available"
}


### VPC

resource "aws_vpc" "terraform_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}



### Public Subnets

resource "aws_subnet" "terraform_public_subnet_1" {
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = var.public_subnet_1_cidr
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.terraform_vpc.id
  tags = {
    Name = "${var.project_name}-public-subnet01"
  }

}



resource "aws_subnet" "terraform_public_subnet_2" {
  availability_zone       = data.aws_availability_zones.available.names[1]
  cidr_block              = var.public_subnet_2_cidr
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.terraform_vpc.id
  tags = {
    Name = "${var.project_name}-public-subnet02"
  }

}




resource "aws_subnet" "terraform_public_subnet_3" {
  availability_zone       = data.aws_availability_zones.available.names[2]
  cidr_block              = var.public_subnet_3_cidr
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.terraform_vpc.id
  tags = {
    Name = "${var.project_name}-public-subnet03"
  }

}



### Private Subnets

resource "aws_subnet" "terraform_private_subnet_1" {
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = var.private_subnet_1_cidr
  vpc_id            = aws_vpc.terraform_vpc.id
  tags = {
    Name = "${var.project_name}-private-subnet-01"
  }

}


resource "aws_subnet" "terraform_private_subnet_2" {
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = var.private_subnet_2_cidr
  vpc_id            = aws_vpc.terraform_vpc.id
  tags = {
    Name = "${var.project_name}-private-subnet02"
  }

}


resource "aws_subnet" "terraform_private_subnet_3" {
  availability_zone = data.aws_availability_zones.available.names[2]
  cidr_block        = var.private_subnet_3_cidr
  vpc_id            = aws_vpc.terraform_vpc.id
  tags = {
    Name = "${var.project_name}-private-subnet03"
  }

}


### Internet Gateway

resource "aws_internet_gateway" "terraform_igw" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

### Public Route Table

resource "aws_route_table" "terraform_public_rtb" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_igw.id
  }


  tags = {
    Name = "${var.project_name}-public-rtb"
  }
}

### Public Subnet 1 Route Table Association

resource "aws_route_table_association" "terraform_public_subnet01_rtb_assoc" {
  subnet_id      = aws_subnet.terraform_public_subnet_1.id
  route_table_id = aws_route_table.terraform_public_rtb.id
}


### Public Subnet 2 Route Table Association

resource "aws_route_table_association" "terraform_public_subnet02_rtb_assoc" {
  subnet_id      = aws_subnet.terraform_public_subnet_2.id
  route_table_id = aws_route_table.terraform_public_rtb.id
}


### Public Subnet 3 Route Table Association

resource "aws_route_table_association" "terraform_public_subnet03_rtb_assoc" {
  subnet_id      = aws_subnet.terraform_public_subnet_3.id
  route_table_id = aws_route_table.terraform_public_rtb.id
}

### Elastic IP 1

resource "aws_eip" "terraform_eip01" {
  depends_on = [aws_internet_gateway.terraform_igw]
}


### Elastic IP 2

resource "aws_eip" "terraform_eip02" {
  depends_on = [aws_internet_gateway.terraform_igw]
}


### Elastic IP 3

resource "aws_eip" "terraform_eip03" {
  depends_on = [aws_internet_gateway.terraform_igw]
}


### Nat Gateway 1

resource "aws_nat_gateway" "terraform_natgw01" {
  allocation_id = aws_eip.terraform_eip01.id
  subnet_id     = aws_subnet.terraform_public_subnet_1.id

  tags = {
    Name = "${var.project_name}-natgw01"
  }

  depends_on = [aws_internet_gateway.terraform_igw]
}



### Nat Gateway 2

resource "aws_nat_gateway" "terraform_natgw02" {
  allocation_id = aws_eip.terraform_eip02.id
  subnet_id     = aws_subnet.terraform_public_subnet_2.id

  tags = {
    Name = "${var.project_name}-natgw02"
  }

  depends_on = [aws_internet_gateway.terraform_igw]
}



### Nat Gateway 3

resource "aws_nat_gateway" "terraform_natgw03" {
  allocation_id = aws_eip.terraform_eip03.id
  subnet_id     = aws_subnet.terraform_public_subnet_3.id

  tags = {
    Name = "${var.project_name}-natgw03"
  }

  depends_on = [aws_internet_gateway.terraform_igw]
}



### Private Route Table 1

resource "aws_route_table" "terraform_private_rtb01" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.terraform_natgw01.id
  }


  tags = {
    Name = "${var.project_name}-private-rtb01"
  }
}



### Private Route Table 2

resource "aws_route_table" "terraform_private_rtb02" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.terraform_natgw02.id
  }


  tags = {
    Name = "${var.project_name}-private-rtb02"
  }
}



### Private Route Table 3

resource "aws_route_table" "terraform_private_rtb03" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.terraform_natgw03.id
  }


  tags = {
    Name = "${var.project_name}-private-rtb03"
  }
}



### Private Subnet 1 Route Table Association

resource "aws_route_table_association" "terraform_private_subnet01_rtb_assoc" {
  subnet_id      = aws_subnet.terraform_private_subnet_1.id
  route_table_id = aws_route_table.terraform_private_rtb01.id
}



### Private Subnet 2 Route Table Association

resource "aws_route_table_association" "terraform_private_subnet02_rtb_assoc" {
  subnet_id      = aws_subnet.terraform_private_subnet_2.id
  route_table_id = aws_route_table.terraform_private_rtb02.id
}



### Private Subnet 3 Route Table Association

resource "aws_route_table_association" "terraform_private_subnet03_rtb_assoc" {
  subnet_id      = aws_subnet.terraform_private_subnet_3.id
  route_table_id = aws_route_table.terraform_private_rtb03.id
}

### Bastion Host AMI Data

data "aws_ami" "terraform_bastion_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.6.20250115.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp3"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }


  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}

output "bastion_ami" {
  value = data.aws_ami.terraform_bastion_ami.id
}


### Bastion Host Security Group

resource "aws_security_group" "terraform_bastion_sg" {
  name        = "bastion_sg"
  description = "Allow SSH to Bastion Host"
  vpc_id      = aws_vpc.terraform_vpc.id

  tags = {
    Name = "${var.project_name}-bastion-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.terraform_bastion_sg.id
  cidr_ipv4         = var.ssh_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.terraform_bastion_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


### SSH Key Pair

resource "aws_key_pair" "terraform_bastion_keypair" {
  key_name   = "${var.project_name}-bastion-keypair"
  public_key = file(var.ssh_public_key_location)
}


### Bastion Host EC2 Instance

resource "aws_instance" "terraform_bastion_host" {
  ami                    = data.aws_ami.terraform_bastion_ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.terraform_public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.terraform_bastion_sg.id]
  key_name               = aws_key_pair.terraform_bastion_keypair.key_name
  tags = {
    Name = "${var.project_name}-bastion-host"
  }
}
