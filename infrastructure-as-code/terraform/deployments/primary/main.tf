resource "aws_vpc" "so-main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "so-vpc"
  }
}

resource "aws_subnet" "so-public-1" {
  vpc_id                  = aws_vpc.so-main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "so-public-2" {
  vpc_id                  = aws_vpc.so-main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "so-igw" {
  vpc_id = aws_vpc.so-main.id
}

resource "aws_route_table" "so-rt" {
  vpc_id = aws_vpc.so-main.id
}

resource "aws_route" "so-internet" {
  route_table_id         = aws_route_table.so-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.so-igw.id
}

resource "aws_route_table_association" "so-rta-1" {
  subnet_id      = aws_subnet.so-public-1.id
  route_table_id = aws_route_table.so-rt.id
}

resource "aws_route_table_association" "so-rta-2" {
  subnet_id      = aws_subnet.so-public-2.id
  route_table_id = aws_route_table.so-rt.id
}

resource "aws_security_group" "so-alb-sg" {
  vpc_id = aws_vpc.so-main.id

  ingress {
    description = "Allow HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "so-web-sg" {
  vpc_id = aws_vpc.so-main.id

  ingress {
    description     = "Allow HTTP only from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.so-alb-sg.id]
  }

  ingress {
    description = "Allow SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["49.204.132.152/32"]
  }

  egress {
    description = "Allow outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "so-web" {
  count         = 2
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t2.micro"

  subnet_id = element([
    aws_subnet.so-public-1.id,
    aws_subnet.so-public-2.id
  ], count.index)

  vpc_security_group_ids = [aws_security_group.so-web-sg.id]

  user_data = file("userdata.sh")

  tags = {
    Name = "web-${count.index}"
  }
}

resource "aws_lb_target_group" "tg" {
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.so-main.id
  target_type = "instance"

  health_check {
    path     = "/"
    protocol = "HTTP"
  }
}


resource "aws_lb_target_group_attachment" "so-tg-attach" {
  count            = 2
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.so-web[count.index].id
  port             = 80
}

resource "aws_lb" "so-alb" {
  load_balancer_type = "application"
  subnets = [
    aws_subnet.so-public-1.id,
    aws_subnet.so-public-2.id
  ]
  security_groups = [aws_security_group.so-alb-sg.id]
}

resource "aws_lb_listener" "so-listener" {
  load_balancer_arn = aws_lb.so-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}