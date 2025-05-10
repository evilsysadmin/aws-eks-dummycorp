#!/usr/bin/env bash

# Solicitar la nueva contraseña al usuario
echo "Type new password:"
read -s password
echo

# Generar el hash BCrypt de la contraseña
bcrypt_pass=$(argocd account bcrypt --password "$password")

# Actualizar el Secreto en Kubernetes
kubectl -n argocd patch secret argocd-secret \
  -p "{\"stringData\": {\"admin.password\": \"$bcrypt_pass\", \"admin.passwordMtime\": \"$(date +%FT%T%Z)\"}}"

echo "Password updated successfully."
