#!/bin/bash
# to run in root ./bin/build-k8s.sh

# Don't forget to set export 
# export COMPOSER_AUTH='{"github-oauth":{"github.com":"<token>"}}'

composer install --no-dev --prefer-dist --optimize-autoloader

# Generate a timestamp in the desired format (e.g., YYYYMMDDHHMMSS)
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# Define the tag with the timestamp appended
TAG="6.7.1-php8.3-fpm-alpine-$TIMESTAMP"

# Build the Docker image
docker buildx build \
  --platform linux/arm64 \
  --build-arg COMPOSER_AUTH=$COMPOSER_AUTH \
  -t browna2/wordpress-ms:$TAG \
  -f prod/wordpress.dockerfile \
  . \
  --no-cache \
  --load

# Push the Docker image to the registry
docker push browna2/wordpress-ms:$TAG
