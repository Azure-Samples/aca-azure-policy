// Scope
targetScope = 'subscription'

// Parameters
@description('Specifies the location of the deployment.')
param location string

@description('Specifies the policy definition to assign.')
param policy object

@description('Specifies the resource id of the policy definition to assign.')
param policyDefinitionId string

// Resources
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: uniqueString('${policy.name}')
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: policy.definition.properties.description
    displayName: policy.definition.properties.displayName
    policyDefinitionId: policyDefinitionId
    parameters: policy.parameters
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (policy.identity) {
  name: guid('${policy.name}')
  properties: {
    roleDefinitionId: policy.policyDefinition.properties.policyRule.then.details.roleDefinitionIds[0]
    principalId: policyAssignment.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Outputs
output policyAssignmentId string = policyAssignment.id
output principalId string = policyAssignment.identity.principalId
