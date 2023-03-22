#!/bin/bash

# Variables
location='westeurope'
deploymentName='policy-deployment'
template="../bicep/main.bicep"
parameters="../bicep/main.parameters.json"
whatIf=1
validate=1

# Subscription id, subscription name, and tenant id of the current subscription
subscriptionId=$(az account show --query id --output tsv)
subscriptionName=$(az account show --query name --output tsv)
tenantId=$(az account show --query tenantId --output tsv)

if [[ $validate == 1 ]]; then
  if [[ $whatIf == 1 ]]; then
    # Execute a deployment What-If operation at resource group scope.
    echo "Previewing changes deployed by [$template] Bicep template..."
    az deployment sub what-if \
      --name $deploymentName \
      --location $location \
      --template-file $template \
      --parameters $parameters \
      --parameters location=$location

    if [[ $? == 0 ]]; then
      echo "[$template] Bicep template validation succeeded"
    else
      echo "Failed to validate [$template] Bicep template"
      exit
    fi
  else
    # Validate the Bicep template
    echo "Validating [$template] Bicep template..."
    output=$(az deployment sub validate \
      --name $deploymentName \
      --location $location \
      --template-file $template \
      --parameters $parameters \
      --parameters location=$location)

    if [[ $? == 0 ]]; then
      echo "[$template] Bicep template validation succeeded"
    else
      echo "Failed to validate [$template] Bicep template"
      echo $output
      exit
    fi
  fi
fi 

# Deploy infrastructure
az deployment sub create \
  --name $deploymentName \
  --location $location \
  --template-file $template \
  --parameters $parameters \
  --parameters location=$location

if [[ $? == 0 ]]; then
  echo "[$deploymentName] deployment successfully created in the [$subscriptionName] subscription"
else
  echo "Failed to create [$deploymentName] deployment in the [$subscriptionName] subscription"
  exit -1
fi
