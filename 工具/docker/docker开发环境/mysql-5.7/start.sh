#!/bin/bash
docker run -it -d --rm --name mysql_1 -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password123456 mysql:5.7