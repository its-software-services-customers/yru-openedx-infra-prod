#!/bin/bash

# To access : http://10.10.5.9:9001/

VAULT_BUCKET=$1
BACKUP_DIR=$(pwd)/data/backup
SECRET_FILE=secrets-prod.txt

sudo mkdir -p ${BACKUP_DIR}
sudo chown yruadmin:yruadmin -R ${BACKUP_DIR}

gsutil cp gs://${VAULT_BUCKET}/prod/${SECRET_FILE} .

set -o allexport; source "${SECRET_FILE}"; set +o allexport

MINIO_ACCESS_KEY=$(echo "${MINIO_ACCESS_KEY}" | tr -d '\r')
MINIO_SECRET_KEY=$(echo "${MINIO_SECRET_KEY}" | tr -d '\r')

sudo docker container stop minio
sudo docker container rm minio

sudo docker run \
  -d \
  -p 9000:9000 \
  -p 9001:9001 \
  -e MINIO_ROOT_USER=${MINIO_ACCESS_KEY} \
  -e MINIO_ROOT_PASSWORD=${MINIO_SECRET_KEY} \
  -v ${BACKUP_DIR}:/data \
  --name minio \
  minio/minio server /data --console-address ":9001"
