#!/bin/bash
pubKeyFile="/root/.ssh/authorized_keys"
if [ ! -e "$file" ]; then
    mkdir -p /root/.ssh
    touch $pubKeyFile
fi
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3P7UQANo5puN9ylMCk8QtQuo8s81o/LNA+O/s3sowfzjNsEJ0yPLyI8VDl9rTpLB1ovP/zC4I4x18t9sTiVvK2sNz3hP3FqiZhXSVoG60yxpyq5xM+8u3nU4HnUR7X+MohJIzfmpwS0/sT+I+7egN/qr5CqLqCZdRhAM+Hmeyw5YWPsU7x/s9KM3piWGkxKeb1m9jmtMtYI4pw70AWr/1iu8F8+yK0ojcCXam06l+YPb58Hrx2GjnMnSREWN4hH12bsdOpuZRVQMbXp0+O1tIckvfDDxzFpeMzQCQKxdOqlEky/SRpoVnL0OhjSXUk0K2KeUpuPN7XRewjHD6q97FJbaV+qbsvzZVGZjFhRQgbNPpGfGvnZz8XbS7+Fba16NJ9gNvkGX8pmh2ekR3DOiGQjObiu/jkLSuUGM2zKBzlLt2kgBH/itp2HFk5nvXQ00Chht9ZYWvnULxR6tSYoOvpTOcXlEJZW6hp/pF5IJ70rzPag3CG8X7+IGOK1q1d7M= github.hood.np
">> $pubKeyFile
