provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}

data "aws_vpc" "default" {
default = true
}

resource "aws_security_group" "alb" {
    name = "terraform-alb-security-group"

    ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "instance" {
  name = "terraform-instance-security-group"

  ingress {
    from_port	    = 80
    to_port	        = 80
    protocol	    = "tcp"
    cidr_blocks	    = ["0.0.0.0/0"]
    }
}

resource "aws_lb" "alb" {
    name = "terraform-alb"
    load_balancer_type = "application"
    subnets = data.aws_subnet_ids.default.ids
    security_groups = [aws_security_group.alb.id]
    idle_timeout = 600
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.alb.arn
    port = 80
    protocol = "HTTP"
    default_action {
        type = "fixed-response"
        fixed_response {
        content_type = "text/plain"
        message_body = "404: not found"
        status_code = 404
        }
    }
}

resource "aws_lb_listener_rule" "asg-listener_rule" {
    listener_arn    = aws_lb_listener.http.arn
    priority        = 100

    condition {
        path_pattern {
        values  = ["*"]
      }
    }

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.asg-target-group.arn
    }
}

resource "aws_lb_target_group" "asg-target-group" {
    name = "terraform-aws-lb-target-group"
#    port = 8080
    port = 80
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id

    health_check {
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200"
        interval            = 15
        timeout             = 3
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }
}


resource "aws_autoscaling_group" "ec2" {
    launch_configuration = aws_launch_configuration.ec2.name
    vpc_zone_identifier = data.aws_subnet_ids.default.ids
    target_group_arns = [aws_lb_target_group.asg-target-group.arn]
    health_check_type = "ELB"

    min_size = 2
    max_size = 3
    tag {
    key = "Name"
    value = "terraform-asg-ec2"
    propagate_at_launch = true
    }
}

resource "aws_launch_configuration" "ec2" {
    image_id = "ami-0dcc0ebde7b2e00db"
    instance_type = "t3.micro"
    security_groups = [aws_security_group.instance.id]
                user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo amazon-linux-extras install nginx -y
                sudo systemctl enable nginx
                sudo systemctl start nginx
                echo "Hello, World" > /var/hmtl/index.html
                EOF
    lifecycle {
        create_before_destroy = true
    }
}

output "alb_dns_name" {
    value = aws_lb.alb.dns_name
    description = "Domain name ALB"
}
