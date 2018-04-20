resource "aws_s3_bucket" "deploy" {
  bucket_prefix = "scoutcamp-${terraform.workspace}-deployment"
  force_destroy = true
}

resource "aws_codepipeline" "cp" {
  lifecycle {
    # These two attributes in ignore changes are just terraform quirks.
    ignore_changes = ["stage.0.action.0.configuration.OAuthToken", "stage.0.action.0.configuration.%"]
  }
  artifact_store {
    location = "${aws_s3_bucket.deploy.bucket}"
    type = "S3"
  }
  name = "${terraform.env}"

  role_arn = "${aws_iam_role.pipeline.arn}"
  stage {
    name = "Source"
    action {
      name = "SourceAction"
      category = "Source"
      owner = "ThirdParty"
      provider = "GitHub"
      version = "1"
      output_artifacts = ["SourceOutput"]
      configuration {
        Owner = "mikkeldamsgaard"
        Repo = "scoutcamp"
        PollForSourceChanges = "true"
        Branch = "${local.git_branch}"
        OAuthToken = "${local.oauth}"
      }
      run_order = 1
    }
  }

  stage {
    name = "Build"
    action {
      name = "Build"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["SourceOutput"]
      output_artifacts = ["BuildArtifact"]
      configuration {
        ProjectName = "${aws_codebuild_project.build.name}"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name= "DeployApp"
      category = "Deploy"
      owner = "AWS"
      provider = "CodeDeploy"
      version = "1"
      input_artifacts = ["BuildArtifact"]
      configuration {
        ApplicationName = "${aws_codedeploy_app.app.name}"
        DeploymentGroupName = "${aws_codedeploy_deployment_group.app.deployment_group_name}"
      }
      run_order = 1
    }
  }
}

resource "aws_codebuild_project" "build" {
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/eb-java-8-amazonlinux-64:2.4.3"
    type = "LINUX_CONTAINER"
  }
  name = "${terraform.workspace}-build"
  source {
    type = "CODEPIPELINE"
    buildspec = "terraform/cicd/buildspec.yml"
  }
  service_role = "${aws_iam_role.codebuild.arn}"
}

resource "aws_codedeploy_app" "app" {
  name = "${terraform.workspace}"
}

resource "aws_codedeploy_deployment_group" "app" {
  app_name = "${aws_codedeploy_app.app.name}"
  deployment_group_name = "app"
  service_role_arn = "${aws_iam_role.code_deploy.arn}"
  autoscaling_groups = ["${aws_autoscaling_group.api.id}"]
}

resource "aws_iam_role" "code_deploy" {
  name = "${terraform.workspace}-code-deploy"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "code_deploy_policy" {
  name = "${terraform.workspace}-code-deploy"
  role = "${aws_iam_role.code_deploy.id}"
  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "ec2:Describe*",
        "ec2:TerminateInstances"
      ],
      "Resource": [
        "*"
      ],
      "Effect": "Allow"
    },
    {
      "Action": [
        "autoscaling:*"
      ],
      "Resource": [
        "*"
      ],
      "Effect": "Allow"
    },
    {
      "Action": [
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeInstanceHealth",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer"
      ],
      "Resource": [
        "*"
      ],
      "Effect": "Allow"
    },
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    },
    {
      "Action": [
        "Tag:getResources",
        "Tag:getTags",
        "Tag:getTagsForResource",
        "Tag:getTagsForResourceList"
      ],
      "Resource": [
        "*"
      ],
      "Effect": "Allow"
    }
  ]
}
EOF
}



resource "aws_iam_role" "pipeline" {
  name = "${terraform.env}-pipeline"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codepipeline.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "pipeline" {
  name = "${terraform.env}-pipeline"
  role = "${aws_iam_role.pipeline.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:*" ,
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "codebuild" {
  name = "${terraform.env}-codebuild"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild" {
  name = "${terraform.env}-codebuild"
  role = "${aws_iam_role.codebuild.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CloudWatchLogsPolicy",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "S3GetObjectPolicy",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "S3PutObjectPolicy",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}