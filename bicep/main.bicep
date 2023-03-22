// Scope
targetScope = 'subscription'

// Parameters
@description('Specifies the location of the deployment.')
param location string

@description('List of policy definitions')
param policies array = [
  {
    name: 'aca-insecure-connections'
    definition: json(loadTextContent('../policy-definitions/aca-insecure-connections.json'))
    parameters: {
      effect: {
        value: 'Audit'
      }
    }
    identity: false
  }
  {
    name: 'aca-allowed-locations'
    definition: json(loadTextContent('../policy-definitions/aca-allowed-locations.json'))
    parameters: {
      listOfAllowedLocations: {
        value: [
          'northeurope'
          'westeurope'
          'eastus2'
        ]
      }
      effect: {
        value: 'Audit'
      }
    }
    identity: false
  }
  {
    name: 'aca-allowed-container-registries'
    definition: json(loadTextContent('../policy-definitions/aca-allowed-container-registries.json'))
    parameters: {
      listOfAllowedContainerRegistries: {
        value: [
          'mcr.microsoft.com'
          'docker.io'
          'dapriosamples'
        ]
      }
      effect: {
        value: 'Audit'
      }
    }
    identity: false
  }
  {
    name: 'aca-allowed-ingress-target-ports'
    definition: json(loadTextContent('../policy-definitions/aca-allowed-ingress-target-ports.json'))
    parameters: {
      listOfAllowedIngressTargetPorts: {
        value: [
          443
          80
        ]
      }
    }
    identity: false
  }
  {
    name: 'aca-allowed-ingress-transports'
    definition: json(loadTextContent('../policy-definitions/aca-allowed-ingress-transports.json'))
    parameters: {
      listOfAllowedIngressTransports: {
        value: [
          'http'
          'http2'
          'auto'
        ]
      }
      effect: {
        value: 'Audit'
      }
    }
    identity: false
  }
  {
    name: 'aca-replica-count'
    definition: json(loadTextContent('../policy-definitions/aca-replica-count.json'))
    parameters: {
      minReplicas: {
        value: 0
      }
      maxReplicas: {
        value: 30
      }
      effect: {
        value: 'Audit'
      }
    }
    identity: false
  }
  {
    name: 'aca-no-liveness-probes'
    definition: json(loadTextContent('../policy-definitions/aca-no-liveness-probes.json'))
    parameters: {
      effect: {
        value: 'Audit'
      }
    }
    identity: false
  }
  {
    name: 'aca-no-readiness-probes'
    definition: json(loadTextContent('../policy-definitions/aca-no-readiness-probes.json'))
    parameters: {
      effect: {
        value: 'Audit'
      }
    }
    identity: false
  }
  {
    name: 'aca-no-startup-probes'
    definition: json(loadTextContent('../policy-definitions/aca-no-startup-probes.json'))
    parameters: {
      effect: {
        value: 'Audit'
      }
    }
    identity: false
  }
  {
    name: 'aca-required-cpu-and-memory'
    definition: json(loadTextContent('../policy-definitions/aca-required-cpu-and-memory.json'))
    parameters: {
      maxCpu: {
        value: '1.0'
      }
      maxMemory: {
        value: '2.5'
      }
      effect: {
        value: 'Audit'
      }
    }
    identity: false
  }
  {
    name: 'aca-no-monitoring'
    definition: json(loadTextContent('../policy-definitions/aca-no-monitoring.json'))
    parameters: {
      effect: {
        value: 'Audit'
      }
    }
    identity: false
  }
  {
    name: 'aca-no-diagnostic-settings'
    definition: json(loadTextContent('../policy-definitions/aca-no-diagnostic-settings.json'))
    parameters: {
      logsEnabled: {
        value: true
      }
      metricsEnabled: {
        value: true
      }
      effect: {
        value: 'AuditIfNotExists'
      }
    }
    identity: false
  }
]

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = [for policy in policies: {
  name: guid(policy.name)
  properties: {
    description: policy.definition.properties.description
    displayName: policy.definition.properties.displayName
    metadata: policy.definition.properties.metadata
    mode: policy.definition.properties.mode
    parameters: policy.definition.properties.parameters
    policyType: policy.definition.properties.policyType
    policyRule: policy.definition.properties.policyRule
  }
}]

module policyAssignment './assignment.bicep' = [for (policy, i) in policies: {
  name: 'poAssign_${take(policy.name, 40)}'
  params: {
    policy: policy
    location: location
    policyDefinitionId: policyDefinition[i].id
  }
  dependsOn: [
    policyDefinition
  ]
}]
