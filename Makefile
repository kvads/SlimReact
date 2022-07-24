init: docker-down-clear docker-pull docker-build docker-up
up: docker-up
down: docker-down
restart: down up

docker-up:
	docker-compose up -d
docker-down:
	docker-compose down --remove-orphans
docker-down-clear:
	docker-compose down -v --remove-orphans
docker-pull:
	docker-compose pull
docker-build:
	docker-compose build
docker-prune:
	docker system prune -a

build: build-gateway build-frontend build-api

build-gateway:
	docker --log-level=debug build --pull --file=gateway/docker/prod/nginx/Dockerfile --tag=${REGISTRY}/auction-gateway:${IMAGE_TAG} gateway/docker
build-frontend:
	docker --log-level=debug build --pull --file=frontend/docker/prod/nginx/Dockerfile --tag=${REGISTRY}/auction-frontend:${IMAGE_TAG} frontend
build-api:
	docker --log-level=debug build --pull --file=api/docker/prod/php-fpm/Dockerfile --tag=${REGISTRY}/auction-api-php-fpm:${IMAGE_TAG} api
	docker --log-level=debug build --pull --file=api/docker/prod/nginx/Dockerfile --tag=${REGISTRY}/auction-api:${IMAGE_TAG} api
try-build:
	REGISTRY=localhost IMAGE_TAG=0 make build

push: push-gateway push-frontend push-api

push-gateway:
	docker push ${REGISTRY}/auction-gateway:${IMAGE_TAG}
push-frontend:
	docker push ${REGISTRY}/auction-frontend:${IMAGE_TAG}
push-api:
	docker push ${REGISTRY}/auction-api:${IMAGE_TAG}
	docker push ${REGISTRY}/auction-api-php-fpm:${IMAGE_TAG}

deploy:
	ssh ${HOST} -p ${PORT} 'rm -rf auction_${BUILD_NUMBER}'
	ssh ${HOST} -p ${PORT} 'mkdir auction_${BUILD_NUMBER}'
	scp -P ${PORT} docker-compose-prod.yml ${HOST}:auction_${BUILD_NUMBER}/docker-compose-prod.yml
	ssh ${HOST} -p ${PORT} 'cd auction_${BUILD_NUMBER} && echo "COMPOSE_PROJECT_NAME=auction" >> .env'
	ssh ${HOST} -p ${PORT} 'cd auction_${BUILD_NUMBER} && echo "REGISTRY=${REGISTRY}" >> .env'
	ssh ${HOST} -p ${PORT} 'cd auction_${BUILD_NUMBER} && echo "IMAGE_TAG=${IMAGE_TAG}" >> .env'
	ssh ${HOST} -p ${PORT} 'cd auction_${BUILD_NUMBER} && docker-compose -f docker-compose-prod.yml pull'
	ssh ${HOST} -p ${PORT} 'cd auction_${BUILD_NUMBER} && docker-compose -f docker-compose-prod.yml up --build --remove-orphans -d'
	ssh ${HOST} -p ${PORT} 'rm -f auction'
	ssh ${HOST} -p ${PORT} 'ln -sr auction_${BUILD_NUMBER} auction'