#!/bin/sh

docker volume create --name=logs
docker-compose up --build
