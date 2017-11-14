#!/bin/bash
KCTL=$(which kubectl)
NSFILE=./namespaces.json
SCFILE=./storage-classes.json
SVCFILE=./services.json
DUMPFILE=./cluster-dump.json

function import_namespaces() {
    echo "Importing namespaces from ${NSFILE}..."
    $KCTL create -f $NSFILE
    echo "DONE!"
}
function import_storage_classes() {
    echo "Importing StorageClasses from ${SCFILE}..."
    $KCTL create -f $SCFILE
    echo "DONE!"
}
function import_services() {
    echo "Importing services from ${SVCFILE}..."
    $KCTL create -f $SVCFILE
    echo "DONE!"
}
function import_resources() {
    echo "Importing cluster resources from ${DUMPFILE}..."
    $KCTL create -f $DUMPFILE
    echo " "
    echo "DONE! Please, now check if the resources were successfully imported."
    echo "Run:"
    echo "- kubectl get ns"
    echo "- kubectl get po --all-namespaces."
    echo "- kubectl get svc --all-namespaces."
}

import_namespaces
import_storage_classes
import_services
import_resources
