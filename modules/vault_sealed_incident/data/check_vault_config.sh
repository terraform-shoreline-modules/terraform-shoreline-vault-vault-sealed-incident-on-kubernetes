

#!/bin/bash



# Set variables

NAMESPACE=${NAMESPACE}

VAULT_POD_NAME=${VAULT_POD_NAME}

VAULT_CONTAINER_NAME=${VAULT_CONTAINER_NAME}



# Check the status of the Vault pod

VAULT_STATUS=$(kubectl get pods -n $NAMESPACE $VAULT_POD_NAME -o jsonpath='{.status.phase}')



if [ "$VAULT_STATUS" != "Running" ]; then

  echo "Vault pod is not running. Current status: $VAULT_STATUS"

  exit 1

fi



# Check the logs of the Vault container

VAULT_LOGS=$(kubectl logs -n $NAMESPACE $VAULT_POD_NAME -c $VAULT_CONTAINER_NAME)



if [[ $VAULT_LOGS == *"configuration file: permission denied"* ]]; then

  echo "Vault configuration file permission denied"

  exit 1

elif [[ $VAULT_LOGS == *"configuration file: no such file or directory"* ]]; then

  echo "Vault configuration file not found"

  exit 1

elif [[ $VAULT_LOGS == *"Error initializing storage of type"* ]]; then

  echo "Vault storage not properly configured"

  exit 1

elif [[ $VAULT_LOGS == *"Error initializing listener of type"* ]]; then

  echo "Vault listener not properly configured"

  exit 1

else

  echo "No issues found with Vault configuration"

  exit 0

fi