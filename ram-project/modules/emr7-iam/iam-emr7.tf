/* EMR Service Role */

resource "aws_iam_role" "EMRClusterServiceRole" {
  name               = "${var.prefix}-${var.emr7_release}-EMRClusterServiceRole"
  assume_role_policy = <<EOF
{
   "Statement": [
      {
        "Action": [
          "sts:AssumeRole"
        ],
        "Effect": "Allow",
        "Principal": {
          "Service": "elasticmapreduce.amazonaws.com"
        }
      }
    ]
}
EOF
/*
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole",
    "arn:aws:iam::aws:policy/AmazonElasticMapReducePlacementGroupPolicy",
    "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
  ]
  */
  
  tags = var.tags
}
resource "aws_iam_role_policy_attachment" "emr_ec2_role" {
  role = aws_iam_role.EMRClusterServiceRole
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "emr_pg_policy" {
  role = aws_iam_role.EMRClusterServiceRole
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticMapReducePlacementGroupPolicy"
}

resource "aws_iam_role_policy_attachment" "emr_role" {
  role = aws_iam_role.EMRClusterServiceRole
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

resource "aws_iam_role_policy" "EMRClusterServiceRolePolicy" {
  name = "${var.prefix}-${var.emr7_release}-EMRClusterServiceRolePolicy"
  role = aws_iam_role.EMRClusterServiceRole.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CreateInTaggedNetwork",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:RunInstances",
                "ec2:CreateFleet",
                "ec2:CreateLaunchTemplate",
                "ec2:CreateLaunchTemplateVersion"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:subnet/*",
                "arn:aws:ec2:*:*:security-group/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/for-use-with-amazon-emr-managed-policies": "true"
                }
            }
        },
        {
            "Sid": "CreateWithEMRTaggedLaunchTemplate",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateFleet",
                "ec2:RunInstances",
                "ec2:CreateLaunchTemplateVersion"
            ],
            "Resource": "arn:aws:ec2:*:*:launch-template/*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/for-use-with-amazon-emr-managed-policies": "true"
                }
            }
        },
        {
            "Sid": "CreateEMRTaggedLaunchTemplate",
            "Effect": "Allow",
            "Action": "ec2:CreateLaunchTemplate",
            "Resource": "arn:aws:ec2:*:*:launch-template/*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/for-use-with-amazon-emr-managed-policies": "true"
                }
            }
        },
        {
            "Sid": "CreateEMRTaggedInstancesAndVolumes",
            "Effect": "Allow",
            "Action": [
                "ec2:RunInstances",
                "ec2:CreateFleet"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:instance/*",
                "arn:aws:ec2:*:*:volume/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/for-use-with-amazon-emr-managed-policies": "true"
                }
            }
        },
        {
            "Sid": "ResourcesToLaunchEC2",
            "Effect": "Allow",
            "Action": [
                "ec2:RunInstances",
                "ec2:CreateFleet",
                "ec2:CreateLaunchTemplate",
                "ec2:CreateLaunchTemplateVersion"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:network-interface/*",
                "arn:aws:ec2:*::image/ami-*",
                "arn:aws:ec2:*:*:key-pair/*",
                "arn:aws:ec2:*:*:capacity-reservation/*",
                "arn:aws:ec2:*:*:placement-group/EMR_*",
                "arn:aws:ec2:*:*:fleet/*",
                "arn:aws:ec2:*:*:dedicated-host/*",
                "arn:aws:resource-groups:*:*:group/*"
            ]
        },
        {
            "Sid": "ManageEMRTaggedResources",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateLaunchTemplateVersion",
                "ec2:DeleteLaunchTemplate",
                "ec2:DeleteNetworkInterface",
                "ec2:ModifyInstanceAttribute",
                "ec2:TerminateInstances"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/for-use-with-amazon-emr-managed-policies": "true"
                }
            }
        },
        {
            "Sid": "ManageTagsOnEMRTaggedResources",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:instance/*",
                "arn:aws:ec2:*:*:volume/*",
                "arn:aws:ec2:*:*:network-interface/*",
                "arn:aws:ec2:*:*:launch-template/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/for-use-with-amazon-emr-managed-policies": "true"
                }
            }
        },
        {
            "Sid": "CreateNetworkInterfaceNeededForPrivateSubnet",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:network-interface/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/for-use-with-amazon-emr-managed-policies": "true"
                }
            }
        },
        {
            "Sid": "TagOnCreateTaggedEMRResources",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:network-interface/*",
                "arn:aws:ec2:*:*:instance/*",
                "arn:aws:ec2:*:*:volume/*",
                "arn:aws:ec2:*:*:launch-template/*"
            ],
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": [
                        "RunInstances",
                        "CreateFleet",
                        "CreateLaunchTemplate",
                        "CreateNetworkInterface"
                    ]
                }
            }
        },
        {
            "Sid": "TagPlacementGroups",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:placement-group/EMR_*"
            ]
        },
        {
            "Sid": "ListActionsForEC2Resources",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeCapacityReservations",
                "ec2:DescribeDhcpOptions",
                "ec2:DescribeImages",
                "ec2:DescribeInstances",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribePlacementGroups",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVolumes",
                "ec2:DescribeVolumeStatus",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeVpcEndpoints",
                "ec2:DescribeVpcs"
            ],
            "Resource": "*"
        },
        {
            "Sid": "CreateDefaultSecurityGroupWithEMRTags",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSecurityGroup"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:security-group/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/for-use-with-amazon-emr-managed-policies": "true"
                }
            }
        },
        {
            "Sid": "CreateDefaultSecurityGroupInVPCWithEMRTags",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSecurityGroup"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:vpc/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/for-use-with-amazon-emr-managed-policies": "true"
                }
            }
        },
        {
            "Sid": "TagOnCreateDefaultSecurityGroupWithEMRTags",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/for-use-with-amazon-emr-managed-policies": "true",
                    "ec2:CreateAction": "CreateSecurityGroup"
                }
            }
        },
        {
            "Sid": "ManageSecurityGroups",
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/for-use-with-amazon-emr-managed-policies": "true"
                }
            }
        },
        {
            "Sid": "CreateEMRPlacementGroups",
            "Effect": "Allow",
            "Action": [
                "ec2:CreatePlacementGroup"
            ],
            "Resource": "arn:aws:ec2:*:*:placement-group/EMR_*"
        },
        {
            "Sid": "DeletePlacementGroups",
            "Effect": "Allow",
            "Action": [
                "ec2:DeletePlacementGroup"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AutoScaling",
            "Effect": "Allow",
            "Action": [
                "application-autoscaling:DeleteScalingPolicy",
                "application-autoscaling:DeregisterScalableTarget",
                "application-autoscaling:DescribeScalableTargets",
                "application-autoscaling:DescribeScalingPolicies",
                "application-autoscaling:PutScalingPolicy",
                "application-autoscaling:RegisterScalableTarget"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ResourceGroupsForCapacityReservations",
            "Effect": "Allow",
            "Action": [
                "resource-groups:ListGroupResources"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AutoScalingCloudWatch",
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricAlarm",
                "cloudwatch:DeleteAlarms",
                "cloudwatch:DescribeAlarms"
            ],
            "Resource": "arn:aws:cloudwatch:*:*:alarm:*_EMR_Auto_Scaling"
        },
        {
            "Sid": "PassRoleForAutoScaling",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::*:role/EMR_AutoScaling_DefaultRole",
            "Condition": {
                "StringLike": {
                    "iam:PassedToService": "application-autoscaling.amazonaws.com*"
                }
            }
        },
        {
            "Sid": "PassRoleForEC2",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::*:instance-profile/BaseInstanceProfileV3",
            "Condition": {
                "StringLike": {
                    "iam:PassedToService": "ec2.amazonaws.com*"
                }
            }
        }
    ]
}
EOF
  
}
/* EMR Instance Profile Role */
resource "aws_iam_role" "EMRClusterInstanceProfileRole" {
  name               = "${var.prefix}-${var.emr7_release}-EMRClusterInstanceProfileRole"
  assume_role_policy = <<EOF
{
    "Statement": [
      {
        "Action": [
          "sts:AssumeRole"
        ],
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        }
      }
    ]
}
  EOF
  /*
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  */
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "emr_ec2_role" {
  role = aws_iam_role.EMRClusterInstanceProfileRole
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role = aws_iam_role.EMRClusterInstanceProfileRole
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}