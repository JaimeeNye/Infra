#!/bin/sh

set -e

docker build --tag infra/tbeteouquoi:latest .

docker push infra/tbeteouquoi:latest
