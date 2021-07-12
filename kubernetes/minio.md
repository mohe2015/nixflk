kubectl minio tenant create minio-tenant-1 --servers 2 --volumes 4 --capacity 2Gi --namespace minio-tenant-1 --storage-class local-path

# TODO switch to k8s probably easier to find documentation / works better