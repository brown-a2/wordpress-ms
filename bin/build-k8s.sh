#!/bin/bash
# to run in root ./bin/build-k8s.sh

# Don't forget to set export 
# export COMPOSER_AUTH='{"github-oauth":{"github.com":"<token>"}}'

composer install --no-dev --prefer-dist --optimize-autoloader

# Define the tag
TAG="6.7.1-php8.3-fpm-alpine"

# Build the Docker image
docker buildx build \
  --platform linux/arm64 \
  --build-arg COMPOSER_AUTH=$COMPOSER_AUTH \
  -t browna2/wordpress-ms:$TAG \
  -f prod/wordpress.dockerfile \
  . \
  --load

# Push the Docker image to the registry
docker push browna2/wordpress-ms:$TAG
