resource "aws_s3_bucket" "frontend" {
  bucket = "scoutcamp-${terraform.workspace}-frontend"
  policy =<<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::scoutcamp-${terraform.workspace}-frontend/*"]
    }
  ]
}
EOF
}