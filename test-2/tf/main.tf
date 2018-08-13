provider "aws" {
  region 		= "${var.aws_region}"
  access_key 	= "${var.aws_access_key}"
  secret_key 	= "${var.aws_secret_key}"
}

module "kinesis_firehose" {
  source			= "modules/data-tracking"
  aws_kinesis_stream_name	= "kinesis-stream"
  aws_kinesis_firehose_name 	= "firehose-stream"
}


