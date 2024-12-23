####################################################
### Local build config
####################################################
run:
	docker compose up -d
	chmod +x bin/upload.sh
	./bin/upload.sh

runprod:
	docker-compose -f docker-compose-prod.yml --env-file /usr/local/bin/.env up -d

down:
	docker compose down --remove-orphans
	docker volume rm ox-build_wordpress_data

build:
	chmod +x bin/build.sh && \
	rm -rf wordpress_data
	./bin/build.sh

buildprod:
	chmod +x bin/build-prod.sh && \
	./bin/build-prod.sh

shell:
	docker exec -it wordpress bash

none:
	docker rmi $(docker images -f "dangling=true" -q)

backup:
	chmod +x bin/backup_script.sh
	./bin/backup_script.sh
	aws s3 cp *.sql s3://totoro-db-backup/ --profile totoros3backup

importtopi:
	chmod +x bin/import_script.sh
	./bin/import_script.sh

importtolocal:
	docker cp backup-db-20240731222254.sql wordpress:/var/www/html
	docker exec -i wordpress wp db import backup-db-20240731222254.sql

syncs3local:
	aws s3 sync s3://totoro-pi-ox-prod/uploads /Users/adam.brown/dev/ox-build/wordpress_data/wp-content/uploads --profile totoros3backup
