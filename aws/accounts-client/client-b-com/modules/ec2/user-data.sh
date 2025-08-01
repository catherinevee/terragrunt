#!/bin/bash

# Update system packages
yum update -y

# Install basic utilities
yum install -y \
  wget \
  curl \
  git \
  unzip \
  jq \
  htop \
  tree

# Configure hostname
hostnamectl set-hostname ${instance_name}

# Create application user
useradd -m -s /bin/bash appuser
echo "appuser:$(openssl rand -base64 32)" | chpasswd

# Create application directory
mkdir -p /opt/app
chown appuser:appuser /opt/app

# Install CloudWatch agent for monitoring
yum install -y amazon-cloudwatch-agent

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "cwagent"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/aws/ec2/${instance_name}/system",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "disk": {
        "measurement": ["used_percent"],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Start CloudWatch agent
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# Log instance information
echo "Instance ${instance_name} initialized in ${environment} environment" >> /var/log/instance-init.log
echo "Initialization completed at $(date)" >> /var/log/instance-init.log

# Signal completion to CloudFormation (if using CloudFormation)
if [ -f /opt/aws/bin/cfn-signal ]; then
  /opt/aws/bin/cfn-signal -e 0 --stack ${AWS::StackName} --resource ${AWS::LogicalResourceId} --region ${AWS::Region}
fi 