#!/usr/bin/env bash

export AWS_REGION=eu-west-1

# Navega al directorio infra y ejecuta el comando terraform
CLUSTER_NAME=$(cd infra && terraform output -raw eks_cluster_name)

# Verifica si se obtuvo el nombre del clúster
if [ -z "$CLUSTER_NAME" ]; then
    echo "Error: cluster_name not found in Terraform output"
    exit 1
else
    # Ejecuta el comando aws con el nombre del clúster
    aws eks update-kubeconfig --name "$CLUSTER_NAME"
fi

