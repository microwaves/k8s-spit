#!/bin/bash
KCTL=$(which kubectl)
JQ=$(which jq)

NSFILE=./namespaces.json
SCFILE=./storage-classes.json
SVCFILE=./services.json
DUMPFILE=./cluster-dump.json

RESOURCES=rc,deploy,secrets,ds,pvc

function dump_namespaces() {
    echo "Dumping namespaces in ${NSFILE}..."

    $KCTL get --export -o=json ns | \
    $JQ '.items[] |
        select(.metadata.name!="kube-system") |
        select(.metadata.name!="kube-public") |
        select(.metadata.name!="default") |
        del(.status,
            .metadata.uid,
            .metadata.selfLink,
            .metadata.resourceVersion,
            .metadata.creationTimestamp,
            .metadata.generation
        )' > $NSFILE

    echo "DONE!"
}

function dump_cluster_resources() {
    dump_storage_classes
    dump_services
    dump_remaining_resources
}

function dump_storage_classes() {
    echo "Dumping storage classes in ${DUMPFILE}..."

    $KCTL get --export -o=json sc | \
    $JQ '.items[] |
        select(.type!="kubernetes.io/service-account-token") |
        select(.metadata.name!="gp2") |
        select(.metadata.name!="default") |
        del(
            .spec.clusterIP,
            .metadata.uid,
            .metadata.selfLink,
            .metadata.resourceVersion,
            .metadata.creationTimestamp,
            .metadata.generation,
            .status,
            .spec.template.spec.securityContext,
            .spec.template.spec.dnsPolicy,
            .spec.template.spec.terminationGracePeriodSeconds,
            .spec.template.spec.restartPolicy,
            .reclaimPolicy
        )' >> $SCFILE

    echo "DONE!"
}

function dump_services() {
    echo "Dumping services in ${SVCFILE}..."

    for ns in $(jq -r '.metadata.name' < $NSFILE);do
        echo "Namespace: $ns"
        $KCTL --namespace="${ns}" get --export -o=json svc | \
        $JQ '.items[] |
            select(.type!="kubernetes.io/service-account-token") |
            del(
                .spec.clusterIP,
                .metadata.uid,
                .metadata.selfLink,
                .metadata.resourceVersion,
                .metadata.creationTimestamp,
                .metadata.generation,
                .status,
                .spec.template.spec.securityContext,
                .spec.template.spec.dnsPolicy,
                .spec.template.spec.terminationGracePeriodSeconds,
                .spec.template.spec.restartPolicy
            )' >> $SVCFILE
    done

    echo "DONE!"
}

function dump_remaining_resources() {
    echo "Dumping remaining cluster resources in ${DUMPFILE}..."

    for ns in $(jq -r '.metadata.name' < $NSFILE);do
        echo "Namespace: $ns"
        $KCTL --namespace="${ns}" get --export -o=json $RESOURCES | \
        $JQ '.items[] |
            select(.type!="kubernetes.io/service-account-token") |
            del(
                .spec.clusterIP,
                .metadata.uid,
                .metadata.selfLink,
                .metadata.resourceVersion,
                .metadata.creationTimestamp,
                .metadata.generation,
                .status,
                .spec.template.spec.securityContext,
                .spec.template.spec.dnsPolicy,
                .spec.template.spec.terminationGracePeriodSeconds,
                .spec.template.spec.restartPolicy
            )' >> $DUMPFILE
    done

    echo "DONE!"
}

dump_namespaces
dump_cluster_resources
echo ""
echo "The export was successful. Now run the k8s-importer.sh."
