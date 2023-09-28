

#!/bin/bash



# Set the namespace and name of the Vault instance

NAMESPACE=${NAMESPACE}

VAULT_NAME=${VAULT_NAME}



# Get the pod name of the Vault instance

POD_NAME=$(kubectl get pods -n $NAMESPACE -l app=$VAULT_NAME -o jsonpath='{.items[0].metadata.name}')



# Unseal the Vault instance

kubectl exec -it $POD_NAME -n $NAMESPACE -- vault operator unseal