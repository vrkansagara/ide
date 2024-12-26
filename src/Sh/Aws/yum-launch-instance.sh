#!/usr/bin/env bash
export CURRENT_DATE=$(date "+%Y%m%d%H%M%S")

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

# Update the system and install necessary packages
${SUDO} yum update -y
${SUDO} yum upgrade -y
${SUDO} yum install nginx -y

# Start the Apache server
${SUDO} systemctl start nginx
${SUDO} systemctl enable nginx


# Fetch the Availability Zone information using IMDSv2
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
AZ=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone`


# Create the index.html file
cat > /usr/share/nginx/html/info.html <<EOF
<div>This instance is located in Availability Zone: $AZ</div>
EOF


echo "instance created on ${CURRENT_DATE}" | ${SUDO} tee /usr/share/nginx/html/index.html