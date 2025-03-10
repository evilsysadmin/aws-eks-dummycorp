#!/bin/bash

# URL para los CRDs de kube-prometheus-stack
CRDS_URL="https://raw.githubusercontent.com/prometheus-community/helm-charts/main/charts/kube-prometheus-stack/crds/crds.yaml"

# Aplicar los CRDs a Kubernetes
echo "Instalando los CRDs de kube-prometheus-stack..."
kubectl apply -f $CRDS_URL

# Verificar que los CRDs se hayan instalado correctamente
echo "Verificando la instalación de los CRDs..."
kubectl get crds | grep prometheus

# Confirmación de la instalación
if [ $? -eq 0 ]; then
  echo "Los CRDs se instalaron correctamente."
else
  echo "Hubo un problema al instalar los CRDs."
fi
