#!/usr/bin/env bash
export CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
export DEBIAN_FRONTEND=noninteractive

if [ "$(whoami)" != "root" ]; then
	SUDO=sudo
fi

${SUDO} apt update -y
${SUDO} apt upgrade -y
${SUDO} apt install nginx -y
${SUDO} systemctl enable nginx
${SUDO} systemctl start nginx

# Fetch the Availability Zone information using IMDSv2
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
AZ=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone`


# Create the index.html file
cat > /var/www/html/info.html <<EOF
<div>This instance is located in Availability Zone: $AZ</div>
EOF


echo "instance created on ${CURRENT_DATE}" | ${SUDO} tee /var/www/html/index.nginx-debian.html