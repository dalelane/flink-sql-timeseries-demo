#!/bin/bash

set -e

# login to OCP registry
export REGISTRY=`oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}'`
docker login -u `oc whoami` -p `oc whoami --show-token` ${REGISTRY}

# build image
docker build -t ${REGISTRY}/event-automation/timeseriesmodel:1 .

# push image to OCP registry
docker push ${REGISTRY}/event-automation/timeseriesmodel:1
