terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Thay đổi bằng Region của bạn
}


resource "aws_sns_topic" "cpu_alert_topic" {
  name = "EC2-CPU-Alerts-Topic"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.cpu_alert_topic.arn
  protocol  = "email"
  endpoint  = "nguyenkhang.28102004@gmail.com" 
}


# 2. CẤU HÌNH CLOUDWATCH ALARM THEO DÕI CPU
resource "aws_cloudwatch_metric_alarm" "cpu_high_alarm" {
  alarm_name          = "EC2-High-CPU-Alarm-80Percent"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1            # Đạt ngưỡng trong 1 datapoint
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300          # 5 phút = 300 giây
  statistic           = "Average"
  threshold           = 80           # Ngưỡng > 80%

  dimensions = {
    # Nhập tay ID của con EC2 bạn cần theo dõi vào đây (hoặc dùng output từ bài 1)
    InstanceId = "i-0bfb99eb4291a701e" 
  }

  alarm_description = "Canh bao khi CPU vuot qua 80% trong 5 phut lien tuc"
  
  # Bắn thông báo sang SNS khi bị Alarm (Vượt ngưỡng)
  alarm_actions = [aws_sns_topic.cpu_alert_topic.arn]
  
  # Bắn thông báo sang SNS khi hệ thống hạ nhiệt về trạng thái bình thường (OK)
  ok_actions    = [aws_sns_topic.cpu_alert_topic.arn]
}