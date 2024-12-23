#!/bin/bash
# Download a copy of the database (whole multisite)

# Generate a timestamp
timestamp=$(date +"%Y%m%d%H%M%S")
backup_file="backup-db-$timestamp.sql"

# SSH into the remote machine using alias
ssh -t pi << ENDSSH
  # Inside the remote machine
  
  # Execute docker command to enter the WordPress container and export the database
  docker exec wordpress wp db export --porcelain /var/www/html/$backup_file

  # Copy the backup file from Docker container to the host machine
  docker cp wordpress:/var/www/html/$backup_file /home/pi/$backup_file

  # Exit SSH session
ENDSSH

# Copy the backup file from the remote machine to the local machine using alias
scp pi:/home/pi/$backup_file .

# Check if the file was successfully copied
if [ $? -eq 0 ]; then

# SSH into the remote machine using alias
ssh -t pi << ENDSSH
  # Inside the remote machine
  
  rm /home/pi/$backup_file
  
  # Execute docker command to enter the WordPress container and export the database
  docker exec wordpress rm /var/www/html/$backup_file

  # Exit SSH session
ENDSSH
  # If the file was successfully copied, delete it from the remote machine

  echo "Backup file successfully copied and deleted from the remote machine."
else
  echo "Failed to copy the backup file from the remote machine."
fi
