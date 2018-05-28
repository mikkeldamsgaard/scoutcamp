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
      name = "Build-Backend"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["SourceOutput"]
      output_artifacts = ["BuildBackendArtifact"]
      configuration {
        ProjectName = "${aws_codebuild_project.build_backend.name}"
      }
    }

    action {
      name = "Build-Frontend"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["SourceOutput"]
      output_artifacts = ["BuildFrontendArtifact"]
      configuration {
        ProjectName = "${aws_codebuild_project.build_frontend.name}"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name= "Deploy-Backend"
      category = "Deploy"
      owner = "AWS"
      provider = "CodeDeploy"
      version = "1"
      input_artifacts = ["BuildBackendArtifact"]
      configuration {
        ApplicationName = "${aws_codedeploy_app.app.name}"
        DeploymentGroupName = "${aws_codedeploy_deployment_group.app.deployment_group_name}"
      }
      run_order = 1
    }

    action {
      name = "Deploy-Frontend"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["BuildFrontendArtifact"]
      output_artifacts = ["dummy"]
      configuration {
        ProjectName = "${aws_codebuild_project.deploy_frontend.name}"
      }
    }
  }
}

resource "aws_codebuild_project" "build_backend" {
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/ubuntu-base:14.04"
    type = "LINUX_CONTAINER"
  }
  name = "${terraform.workspace}-build-backend"
  source {
    type = "CODEPIPELINE"
    buildspec = "terraform/cicd/buildscripts/backend/buildspec.yml"
  }
  service_role = "${aws_iam_role.codebuild.arn}"
}

resource "aws_codebuild_project" "build_frontend" {
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type = "BUILD_GENERAL1_LARGE"
    image = "aws/codebuild/ubuntu-base:14.04"
    type = "LINUX_CONTAINER"
  }
  name = "${terraform.workspace}-build-frontend"
  source {
    type = "CODEPIPELINE"
    buildspec = "terraform/cicd/buildscripts/frontend/buildspec.yml"
  }
  service_role = "${aws_iam_role.codebuild.arn}"
}

resource "aws_codebuild_project" "deploy_frontend" {
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/ubuntu-base:14.04"
    type = "LINUX_CONTAINER"
    environment_variable {
      name = "S3_DEPLOY_BUCKET"
      value = "${aws_s3_bucket.frontend.id}"
    }
  }
  name = "${terraform.workspace}-deploy-frontend"
  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
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