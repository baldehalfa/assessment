#! /bin/bash

aws s3 cp ~/application/storage/logs/*.log s3://application_logs/$(date +"%m_%d_%y")

# to setup the cron job 

# In EC2 instance, run the following command:
# crontab -e
# Add the following line to the end of the file:
# 0 0 * * * /home/ubuntu/infra_deployment/copy_logs.sh
# Save and close the file.
# Then, run the following command to verify the cron job:
# crontab -l
# If the cron job is setup correctly, you should see the following output:
# 0 0 * * * /home/ubuntu/infra_deployment/copy_logs.sh
# You can also run the following command to see the cron job output:
# tail -f /var/log/cron.log
# If the cron job is not setup correctly, you should see the following output:
# No crontab for root
