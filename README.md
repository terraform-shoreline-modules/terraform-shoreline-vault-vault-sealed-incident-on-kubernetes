
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Vault Sealed Incident
---

The Vault Sealed incident type occurs when an instance of the Vault has been sealed due to an error or issue. This can cause disruption to the system and requires immediate attention to resolve the issue and unseal the Vault instance. It is important to identify the root cause of the issue in order to prevent it from happening again in the future.

### Parameters
```shell
export NAMESPACE="PLACEHOLDER"

export POD_NAME="PLACEHOLDER"

export VAULT_POD_NAME="PLACEHOLDER"

export VAULT_CONTAINER_NAME="PLACEHOLDER"

export VAULT_NAME="PLACEHOLDER"
```

## Debug

### List all pods in the namespace
```shell
kubectl get pods -n ${NAMESPACE}
```

### Check if the pod is running
```shell
kubectl describe pod ${POD_NAME} -n ${NAMESPACE}
```

### Check the logs of the pod
```shell
kubectl logs ${POD_NAME} -n ${NAMESPACE}
```

### Check the status of the Vault server
```shell
kubectl exec -it ${VAULT_POD_NAME} -n ${NAMESPACE} -- vault status
```

### Check if the Vault server is sealed
```shell
kubectl exec -it ${VAULT_POD_NAME} -n ${NAMESPACE} -- vault status | grep Sealed
```

### Check the Vault server logs
```shell
kubectl logs ${VAULT_POD_NAME} -n ${NAMESPACE}
```

### Check the Vault server configuration
```shell
kubectl exec -it ${VAULT_POD_NAME} -n ${NAMESPACE} -- vault operator init -status
```

### Check the Vault server health
```shell
kubectl exec -it ${VAULT_POD_NAME} -n ${NAMESPACE} -- vault operator check
```

### Check if the Vault server has sufficient resources
```shell
kubectl describe pod ${VAULT_POD_NAME} -n ${NAMESPACE} | grep -E "Limits|Requests"
```

### Check the Vault server's storage
```shell
kubectl exec -it ${VAULT_POD_NAME} -n ${NAMESPACE} -- vault storage check
```

### Check the Vault server's audit logs
```shell
kubectl exec -it ${VAULT_POD_NAME} -n ${NAMESPACE} -- vault audit list
```

### Issues with the Vault service configuration leading to a failure in the Vault instance.
```shell


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


```

## Repair

### unseal the vault
```shell


#!/bin/bash



# Set the namespace and name of the Vault instance

NAMESPACE=${NAMESPACE}

VAULT_NAME=${VAULT_NAME}



# Get the pod name of the Vault instance

POD_NAME=$(kubectl get pods -n $NAMESPACE -l app=$VAULT_NAME -o jsonpath='{.items[0].metadata.name}')



# Unseal the Vault instance

kubectl exec -it $POD_NAME -n $NAMESPACE -- vault operator unseal


```