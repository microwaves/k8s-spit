k8s-spit
--------
Easy import and export of k8s resources.

## Export

First point the `KUBECONFIG` environment variable to the source k8s:

```
$ export KUBECONFIG=/path/to/source/config
```

Then execute the exporter.

```
$ ./k8s-exporter.sh
```

## Import

After have exported the resources, now point the `KUBECONFIG` to the target k8s:

```
$ export KUBECONFIG=/path/to/target/config
```

And simply execute the importer:

```
$ ./k8s-importer.sh
```

If everything went well during the import, you should be able to see the pods
running executing:

```
kubectl get pods --all-namespaces
```

## Maintainers

Stephano Zanzin - [@microwaves](https://github.com/microwaves)
