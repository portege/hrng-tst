resource "aws_kinesis_stream" "kinesis_stream" {
  name             = "${var.aws_kinesis_stream_name}"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]
}

resource "aws_s3_bucket" "stream_bucket" {
  bucket           = "${var.aws_stream_bucket}"
  acl    = "private"
}

resource "aws_iam_role" "firehose_role" {
  name = "firehose_main_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose" {
  name        = "${var.aws_kinesis_firehose_name}"
  destination = "s3"
  kinesis_source_configuration {
	kinesis_stream_arn = "${aws_kinesis_stream.kinesis_stream.arn}"
	role_arn = "${aws_iam_role.firehose_role.arn}"
  }

  s3_configuration {
    role_arn   = "${aws_iam_role.firehose_role.arn}"
    bucket_arn = "${aws_s3_bucket.stream_bucket.arn}"
  }
}
