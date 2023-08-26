resource "aws_ecs_cluster" "embulk-cluster" {
  name = "embulk-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "provider" {
  cluster_name       = aws_ecs_cluster.embulk-cluster.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}

data "aws_iam_policy_document" "ecs-tasks-assumed-role-document" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "fargate-execution-role" {
  name               = "fargate-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs-tasks-assumed-role-document.json
}


resource "aws_iam_role_policy_attachment" "fargate-ecs-role-attach" {
  role       = aws_iam_role.fargate-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy_attachment" "fargate-ecr-readonly-attach" {
  role       = aws_iam_role.fargate-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "fargate-write-s3-attach" {
  role       = aws_iam_role.fargate-execution-role.name
  policy_arn = aws_iam_policy.allow_s3_policy.arn
}


