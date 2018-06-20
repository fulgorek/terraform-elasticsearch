data "aws_ami" "ec2_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

resource "aws_launch_configuration" "master" {
  name                        = "${var.project}-master"
  image_id                    = "${var.default_ami != "" ? var.default_ami : data.aws_ami.ec2_linux.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.elasticsearch.name}"
  instance_type               = "${var.master_node_instance_type}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = "${var.master_node_public_ip}"
  security_groups             = ["${aws_security_group.elasticsearch.id}"]

  root_block_device {
    volume_type = "${var.master_node_volume_type}"
    volume_size = "${var.master_node_volume_size}"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["user_data"]
  }

  user_data = "${data.template_file.user_data_master.rendered}"
}

data "template_file" "user_data_master" {
  template = "${file("${path.module}/provision/user_data.sh")}"

  vars {
    elasticsearch_version = "${var.elasticsearch_version}"
    cluster_name          = "${var.cluster_name}"
    region                = "${var.region}"
    node_master           = "true"
  }
}

resource "aws_autoscaling_group" "master" {
  name                      = "${var.project}-master-asg"
  launch_configuration      = "${aws_launch_configuration.master.name}"
  vpc_zone_identifier       = ["${split(",", var.master_node_subnets)}"]
  max_size                  = "${var.master_node_count_min}"
  min_size                  = "${var.master_node_count_max}"
  default_cooldown          = 60
  health_check_type         = "EC2"
  health_check_grace_period = "10"
  termination_policies      = ["OldestInstance"]

  enabled_metrics = [
    "GroupMaxSize",
    "GroupMinSize",
    "GroupInServiceInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTotalInstances",
  ]

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "${var.project}-master-node"
  }

  tag {
    key                 = "Project"
    propagate_at_launch = true
    value               = "${var.project}"
  }

  tag {
    key                 = "Environment"
    propagate_at_launch = true
    value               = "${var.environment}"
  }
}

resource "aws_autoscaling_policy" "scale_out_master" {
  adjustment_type = "ChangeInCapacity"
  policy_type     = "StepScaling"

  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = "0"
    metric_interval_upper_bound = ""
  }

  autoscaling_group_name = "${aws_autoscaling_group.master.name}"
  name                   = "simple_scale_out"
}

resource "aws_cloudwatch_metric_alarm" "cpu_greater_than_master" {
  alarm_name          = "${var.cluster_name}_master_cpu_usage_greater_than"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.master.name}"
  }

  alarm_description = "This metric monitors EC2 CPU utilisation greater than 80% on Master nodes"
  alarm_actions     = ["${aws_autoscaling_policy.scale_out_master.arn}"]
}

resource "aws_autoscaling_policy" "scale_in_master" {
  adjustment_type = "ChangeInCapacity"
  policy_type     = "StepScaling"

  step_adjustment {
    scaling_adjustment          = "-1"
    metric_interval_lower_bound = ""
    metric_interval_upper_bound = "0"
  }

  autoscaling_group_name = "${aws_autoscaling_group.master.name}"
  name                   = "${var.cluster_name}_master_simple_scale_in"
}

resource "aws_cloudwatch_metric_alarm" "cpu_less_than_master" {
  alarm_name          = "${var.cluster_name}_master_cpu_usage_less_than"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 20

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.master.name}"
  }

  alarm_description = "This metric monitors EC2 CPU utilisation less than 20% on Master nodes"
  alarm_actions     = ["${aws_autoscaling_policy.scale_in_master.arn}"]
}

data "template_file" "user_data_node" {
  template = "${file("${path.module}/provision/user_data.sh")}"

  vars {
    elasticsearch_version = "${var.elasticsearch_version}"
    cluster_name          = "${var.cluster_name}"
    region                = "${var.region}"
    node_master           = "false"
  }
}

resource "aws_launch_configuration" "data" {
  name                        = "${var.project}-data"
  image_id                    = "${var.default_ami != "" ? var.default_ami : data.aws_ami.ec2_linux.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.elasticsearch.name}"
  instance_type               = "${var.data_node_instance_type}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = "false"
  security_groups             = ["${aws_security_group.elasticsearch.id}"]

  root_block_device {
    volume_type = "${var.data_node_volume_type}"
    volume_size = "${var.data_node_volume_size}"
  }

  lifecycle {
    create_before_destroy = true
  }

  user_data = "${data.template_file.user_data_node.rendered}"
}

resource "aws_autoscaling_group" "data" {
  name                      = "${var.project}-data-asg"
  launch_configuration      = "${aws_launch_configuration.data.name}"
  vpc_zone_identifier       = ["${split(",", var.data_node_subnets)}"]
  max_size                  = "${var.data_node_count_min}"
  min_size                  = "${var.data_node_count_max}"
  default_cooldown          = 60
  health_check_type         = "EC2"
  health_check_grace_period = "10"
  termination_policies      = ["OldestInstance"]

  enabled_metrics = [
    "GroupMaxSize",
    "GroupMinSize",
    "GroupInServiceInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTotalInstances",
  ]

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "${var.project}-data-node"
  }

  tag {
    key                 = "Project"
    propagate_at_launch = true
    value               = "${var.project}"
  }

  tag {
    key                 = "Environment"
    propagate_at_launch = true
    value               = "${var.environment}"
  }
}
