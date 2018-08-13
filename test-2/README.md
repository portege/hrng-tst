# Objective
## Data Ingestion Module
This component pulls data from various data sources into the system's cloud platform. 
> In the future, it is expected that data will come from several sources and might appear in various formats (xml, text, etc). Data ingestion should be designed so that new modules can be added without too much overhead.

If you have chosen this portion of the project to implement, then the implementation should:
- pull data from an S3 bucket using this [link](https://s3-ap-southeast-1.amazonaws.com/tgr-hire-devops-test). Only data from the subfolder `/crypto/01-data-ingestion` should be used.

Each record contains trade prices over a 5 minute interval.
Here is a data dictionary of the fields in the data:

| Name | Type | Description |
| ---- | ---- | ----------- |
| `date` | timestamp | UTC timestamp of the start of the 5 minute interval where the trade data was summarized |
| `high` | float | the highest price for this period. |
| `low` | float | the lowest price for this period. |
| `open` | float | opening price for this period. |
| `close` | float | closing price for this period. |
| `volume` | float | volume of the first currency pair (USDT) |
| `quoteVolume` | float | volume of the second currency pair (ETH) | 
| `weightedAverage` | float |  weighted average of trades |

## Constraint & Limitation ##
### Main Process ###
Data ingestion mainly has two methods:
- Passive: where the data source *pushes* the data into one data collecting service. An example of this method is Tracking service using AWS Kinesis. The tracking only listens on its API and the schema is defined here as well.
- Active: the ingestion process will access from one or many sources and then *collect* the data from there. The application needs to understand about the source (Database engine, schema, authentication) and requires to direct connect to it.

Both methods are using a different methodology and technology to ingest the data. either the data-ingestion service receives the data by actively pulling from the sources or passively gather the data from the sources.

For this design, we will be focusing on the first method, that is creating a tracking system that will provide an endpoint for any platform (desktop, mobile, IoT etc) to ingest their data.

### Security and Performance ###
This design will only cover the basic functionality of the use-case. And will not cover the overall security aspect (IAM Role, WAF, Data quality, Encryption) and Performance point of view (the number of shards, availability zones)

## Assumption ##

## Architecture & Design ##
Essentially, I recommend using managed service on AWS to minimize the day-to-day operation overhead. All the technology will be maintained by AWS, so we can focus more on product and development. The stack as following:
* Kinesis: will responsible for accepting all data from various data sources. 
* Kinesis Firehose: will push the data from Kinesis to any data warehouse.
* S3: will use as data store engine, since it provides a high scalability environment, it also low-cost data store.

```[Kinesis] --> [Kinesis Firehose] --> [S3]```

## Implementation ##
### Infrastructure As a Code ###
In creating Data ingestion infrastructure on AWS, we need to define it as a code for documentation and reusable-module reason. There is two popular option for deployment tools that can be considered, Terraform and AWS CloudFormation. Both have the advantage and disadvantage. 

For this design, I will use Terraform because of its portability and not depends on the cloud vendor. We might deploy the infrastructure on other than AWS such as GCP or Azure in future.

### Terraform implementation ###
The tracking needs at least 4 main component, IAM Role, Kinesis, Kinesis Firehose and S3.
**IAM Role** will handle all the permission that required Kinesis Firehose to access Kinesis stream.
```
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
```
**Kinesis** will work as an intermediary data storage, receiving data from the sources.
```resource "aws_kinesis_stream" "kinesis_stream" {
  name             = "${var.aws_kinesis_stream_name}"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]
}
```
**Kinesis-Firehose** will pull the data from Kinesis and forward it to final data storage.
```resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose" {
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
```
**S3** bucket will act as final data storage
```resource "aws_s3_bucket" "stream_bucket" {
  bucket           = "stream-bucket"
  acl    = "private"
}
```