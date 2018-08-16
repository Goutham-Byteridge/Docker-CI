#!/bin/bash

set -e

# possible -b (base / app name) -i (image version), -e (deploy env) and -s (service id)
while getopts b:i:e:s: option
do
case "${option}"
in
b) BASE_NAME=${OPTARG};;
i) IMG_VERSION=${OPTARG};;
e) DEPLOY_ENV=${OPTARG};;
s) SERVICE_ID=${OPTARG};;
esac
done

echo "BASE_NAME: " $BASE_NAME
echo "IMG_VERSION: " $IMG_VERSION
echo "DEPLOY_ENV: " $DEPLOY_ENV
echo "SERVICE_ID: " $SERVICE_ID

if [ -z "$BASE_NAME" ]; then
    echo "exit: No BASE_NAME specified"
    exit;
fi

if [ -z "$SERVICE_ID" ]; then
    echo "exit: No SERVICE_ID specified"
    exit;
fi

if [ -z "$DEPLOY_ENV" ]; then
    echo "exit: No DEPLOY_ENV specified"
    exit;
fi

if [ -z "$IMG_VERSION" ]; then
    echo "exit: No IMG_VERSION specified"
    exit;
fi

# Define variables
TASK_FAMILY=${BASE_NAME}-${DEPLOY_ENV}-${SERVICE_ID}
SERVICE_NAME=$SERVICE_ID
CLUSTER_NAME=$BASE_NAME

IMGAGE_PACEHOLDER="<IMAGE_VERSION>"

CONTAINER_DEFINITION_FILE=$(cat task-definition.json)
CONTAINER_DEFINITION="${CONTAINER_DEFINITION_FILE//$IMGAGE_PACEHOLDER/$IMG_VERSION}"


export TASK_VERSION=$(aws ecs register-task-definition --family ${TASK_FAMILY} --container-definitions "$CONTAINER_DEFINITION" | jq --raw-output '.taskDefinition.revision')
echo "Registered ECS Task Definition: " $TASK_VERSION


if [ -n "$TASK_VERSION" ]; then
    echo "Update ECS Cluster: " $CLUSTER_NAME
    echo "Service: " $SERVICE_NAME
    echo "Task Definition: " $TASK_FAMILY:$TASK_VERSION
    
    DEPLOYED_SERVICE=$(aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --task-definition $TASK_FAMILY:$TASK_VERSION | jq --raw-output '.service.serviceName')
    echo "Deployment of $DEPLOYED_SERVICE complete"
else
    echo "exit: No task definition"
    exit;
fi