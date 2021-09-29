#!/bin/bash

ACTION=$1

set -o allexport; source .env; set +o allexport
terraform ${ACTION}
