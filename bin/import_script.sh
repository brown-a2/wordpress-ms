#!/bin/bash

# Find the first .sql file in the current directory
backup_file=$(find . -maxdepth 1 -type f -name "*.sql" | sort | head -n 1)

if [ -z "$backup_file" ]; then
    echo "No .sql file found in the current directory."
    exit 1
fi

echo "Using SQL backup file: $backup_file"

# Copy the SQL backup file to the remote machine using SCP
scp $backup_file pi:/home/pi/

# Check if the file was successfully copied
if [ $? -eq 0 ]; then
    echo "Backup file copied successfully to the remote machine."
else
    echo "Failed to copy the backup file to the remote machine."
    exit 1
fi

# SSH into the remote machine and execute commands inside
ssh pi << EOF
    # Define the backup file path
    backup_filename="/home/pi/$(basename "$backup_file")"
    
    # Copy the SQL backup file from host machine to WordPress container
    if docker cp "\$backup_filename" wordpress:/var/www/html/; then
        echo "SQL file copied to WordPress container successfully"
        
        # Enter WordPress container and import the database
        if docker exec -i wordpress wp db import "/var/www/html/$(basename "$backup_file")" --allow-root; then
            echo "Database imported successfully into WordPress container."

            docker exec wordpress rm /var/www/html/$backup_file
            
            # Remove the SQL backup file from host machine
            if rm "\$backup_filename"; then
                echo "SQL file removed from host machine."
            else
                echo "Failed to remove SQL file from host machine."
            fi
        else
            echo "Failed to import database into WordPress container."
        fi
    else
        echo "Failed to copy SQL file to WordPress container."
    fi
EOF

# Check if the commands executed successfully
if [ $? -eq 0 ]; then
    echo "Backup file deleted from the remote machine."
else
    echo "Failed to delete the backup file from the remote machine."
fi
