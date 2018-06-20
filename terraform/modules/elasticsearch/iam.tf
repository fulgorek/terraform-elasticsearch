data "template_file" "iam_role" {
  template = "${file("${path.module}/provision/iam_role.json")}"
}

resource "aws_iam_role" "iam_role" {
  name               = "es_${var.project}_custom_role"
  assume_role_policy = "${data.template_file.iam_role.rendered}"
}

data "template_file" "policy" {
  template = "${file("${path.module}/provision/policy.json")}"
}

resource "aws_iam_role_policy" "policy" {
  name   = "es_${var.project}_custom_policy"
  role   = "${aws_iam_role.iam_role.id}"
  policy = "${data.template_file.policy.rendered}"
}

resource "aws_iam_instance_profile" "elasticsearch" {
  name = "es_${var.project}_custom_profile"
  role = "${aws_iam_role.iam_role.name}"
}
