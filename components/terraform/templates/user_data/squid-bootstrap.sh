#!/bin/bash
#
# DO NOT EDIT BELOW THIS LINE

sudo snap start amazon-ssm-agent
# Install Cloudwatch agent
sudo yum install -y amazon-cloudwatch-agent
# Write Cloudwatch agent configuration file
sudo cat >> /opt/aws/amazon-cloudwatch-agent/bin/config_temp.json <<EOF
{
    "agent": {
            "metrics_collection_interval": 60,
            "run_as_user": "root"
    },
    "metrics": {
            "metrics_collected": {
                    "disk": {
                            "measurement": [
                                    "disk_used_percent"
                            ],
                            "metrics_collection_interval": 60,
                            "resources": [
                                    "*"
                            ]
                    },
                    "mem": {
                            "measurement": [
                                    "mem_used_percent"
                            ],
                            "metrics_collection_interval": 60
                    }
            }
    }
}
EOF
# Start Cloudwatch agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
sudo apt-get update
sudo apt-get install squid -y
wget https://raw.githubusercontent.com/mobilise-academy/config-files/main/squid.conf -O /etc/squid/squid.conf
sudo systemctl start squid