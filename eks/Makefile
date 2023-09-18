.SILENT:
help:
	{ grep --extended-regexp '^[a-zA-Z_-]+:.*#[[:space:]].*$$' $(MAKEFILE_LIST) || true; } \
	| awk 'BEGIN { FS = ":.*#[[:space:]]*" } { printf "\033[1;32m%-22s\033[0m%s\n", $$1, $$2 }'


cluster-create: # create the EKS cluster
	./make.sh cluster-create

write-kubeconfig: # write the kubeconfig file
	./make.sh write-kubeconfig

cluster-delete: # delete the EKS cluster
	./make.sh cluster-delete
