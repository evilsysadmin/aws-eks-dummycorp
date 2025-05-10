#!/usr/bin/env bash

# Lista de namespaces a verificar y borrar
namespaces=("argocd" "core-infra-apps" "monitoring")

# Recorrer la lista de namespaces
for ns in "${namespaces[@]}"; do
  # Verificar si el namespace existe
  if kubectl get namespace "$ns" &>/dev/null; then
    echo "El namespace '$ns' existe. Procediendo a eliminarlo..."
    
    # Si el namespace es 'monitoring', eliminar el Ingress
    if [ "$ns" == "monitoring" ]; then
      kubectl delete ingress -n "$ns"
      echo "Ingress en el namespace '$ns' eliminado correctamente."
    fi
    
    kubectl delete namespace "$ns"
    echo "Namespace '$ns' eliminado correctamente."
  else
    echo "El namespace '$ns' no existe. No es necesario eliminarlo."
  fi
done

echo "Proceso completado."
