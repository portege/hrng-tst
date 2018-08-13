provider "aws" {
  region 	= "${var.aws_region}"
  access_key 	= "${var.aws_access_key}"
  secret_key 	= "${var.aws_secret_key}"
}

module "data_tracking" {
  source			= "modules/data-tracking"
  aws_kinesis_stream_name	= "${var.kinesis_stream}"
  aws_kinesis_firehose_name 	= "${var.firehose_stream}"
  aws_stream_bucket		= "${var.bucket_name}"
}


