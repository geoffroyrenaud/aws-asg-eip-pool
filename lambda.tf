resource "aws_iam_role" "lambda" {
  name = "${var.myname}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.myname}"
  retention_in_days = 7
}

resource "aws_iam_policy" "lambda" {
  name        = "${var.myname}-policy"
  path        = "/"
  description = "IAM policy for ASG EIP Pool Lambda"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:DisassociateAddress",
                "ec2:DescribeAddresses",
                "ec2:AssociateAddress"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:eu-west-1:*:log-group:/aws/lambda/${var.myname}:*"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:eu-west-1:*:*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}


data "archive_file" "lambda_zip_dir" {
  type        = "zip"
  output_path = "lambda.zip"
  source_dir  = "lambda"
}

resource "aws_lambda_function" "lambda" {
  function_name    = var.myname
  filename         = "lambda.zip"
  source_code_hash = data.archive_file.lambda_zip_dir.output_base64sha256
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  role             = aws_iam_role.lambda.arn

  environment {
    variables = {
      foo = "bar"
    }
  }
}
