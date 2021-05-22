provider "aws" {
  region = "ap-southeast-1"
  profile = "default"
}

resource "aws_config_config_rule" "desired_instance_type" {
  name = "desired_instance_type"

  source {
    owner             = "AWS"
    source_identifier = "DESIRED_INSTANCE_TYPE"
  }

  input_parameters = <<EOF
{
  "alarmActionRequired" : "t2.medium"
}
EOF

}