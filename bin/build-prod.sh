#!/bin/bash

##################
# Image Builder
##################

# Installs all the dependancies the multisite image needs and
# then builds the image.

# Required programs that need to be present:
# - Docker - Build the Docker image

# If /wordpress directory exists and rebuild = yes, remove directory
# so that Docker has a fresh WP directory to install into, resolving
# issues with Docker not overwriting older files.

while true; do
    read -p "Rebuilding will delete all local WP files? Continue? [y/n] " yn
    case $yn in
        [Yy]* )
            DIR=wordpress
            # Check if dir exist, if so delete
            if [[ -d "$DIR" ]]; then
                rm -rf $DIR
            fi

            # Determine the path for the .env file and create file. Do not overwrite if .env exists.
            ENV_FILE_PATH="$(pwd)/.env"

            # Check if environment is set to prod
            if [ "$ENVIRONMENT" = "prod" ]; then
                echo "Environment is set to 'prod'. Skipping creation of .env file."
            else
                # Check if .env file already exists
                if [ ! -f "$ENV_FILE_PATH" ]; then
                    # Create .env only if it doesn't exist
                    echo "# Add in custom variables you want to run in the Docker container locally" > "$ENV_FILE_PATH"
                    echo "Generated .env file at $ENV_FILE_PATH"
                else
                    # .env file already exists
                    echo ".env file already exists at $ENV_FILE_PATH. Skipping creation."
                fi
            fi

            # Test Docker is running locally
            if ! docker info > /dev/null 2>&1; then
            echo -e "Oops, where is Docker? Start Docker and try again.\n"
            exit 1
            fi

            # Build Docker images
            echo -e '\n######################'
            echo -e '# Run Docker Build'
            echo -e '######################\n'

            # Check if environment is set to prod
            echo -e 'Running prod build'
            docker-compose -f docker-compose-prod.yml build --no-cache
       
            
            break;;
        [Nn]* )
            exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
