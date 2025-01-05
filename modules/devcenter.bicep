@description('The name of Dev Center e.g. dc-devbox-test')
param devcenterName string

@description('The name of Network Connection e.g. con-devbox-test')
param networkConnectionName string

@description('The name of Dev Center project e.g. dcprj-devbox-test')
param projectName string

@description('raw project name')
param projectDescription string

@description('The resource id of Virtual network subnet')
param subnetId string

@description('Primary location for all resources e.g. eastus')
param location string = resourceGroup().location

@description('Specifies the name of the key vault.')
param keyVaultName string

@description('the catalog name')
param catalogName string

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string = subscription().tenantId

@description('Specifies the name of the secret that you want to create.')
param secretName string = 'githubtoken'

@description('Specifies the value of the secret that you want to create.')
@secure()
param secretValue string = ''

resource devcenter 'Microsoft.DevCenter/devcenters@2024-08-01-preview' = {
  name: devcenterName
  location: location
  properties:{
    projectCatalogSettings: {
      catalogItemSyncEnableStatus: 'Enabled'
    }
    networkSettings: {
      microsoftHostedNetworkEnableStatus: 'Disabled'
    }
    devBoxProvisioningSettings: {
      installAzureMonitorAgentEnableStatus: 'Enabled'
    }
  }
}

resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-08-01-preview' = {
  name: networkConnectionName
  location: location
  dependsOn: [
    devcenter
  ]
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: subnetId
  }
}

resource attachedNetworks 'Microsoft.DevCenter/devcenters/attachednetworks@2024-08-01-preview' = {
  parent: devcenter
  dependsOn: [
    devcenter
  ]
  name: networkConnection.name
  properties: {
    networkConnectionId: networkConnection.id
  }
}

resource project 'Microsoft.DevCenter/projects@2024-08-01-preview' = {
  name: projectName
  location: location
  dependsOn: [
    attachedNetworks
  ]
  identity:{
    type: 'SystemAssigned'
  }
  properties: {
    devCenterId: devcenter.id
    maxDevBoxesPerUser: 1
    displayName: projectDescription
    catalogSettings: {
      catalogItemSyncTypes: [
      'EnvironmentDefinition','ImageDefinition']
    }
  }
}

resource kv 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: 'false'
    enabledForDiskEncryption: 'false'
    enabledForTemplateDeployment: 'false'
    tenantId: tenantId
    enableSoftDelete: true
    enableRbacAuthorization: true
    softDeleteRetentionInDays: 90
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'None'
      ipRules: []
      virtualNetworkRules: []
    }
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  parent: kv
  name: secretName
  properties: {
    value: secretValue
  }
}

resource kvRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(kv.id, '4633458b-17de-408a-b874-0445c86b69e6')
  scope: kv
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User
    principalId: project.identity.principalId
    principalType: 'ServicePrincipal'
  }
}


resource catalog 'Microsoft.DevCenter/projects/catalogs@2024-08-01-preview' = {
  dependsOn: [
    project
  ]
  name: '${project.name}/${catalogName}'
  properties: {
    gitHub: {
      uri: 'https://github.com/jacwu/devbox-teamcustomization-template.git'
      branch: 'main'
      secretIdentifier: secret.properties.secretUri
      path: 'imagedefinitions'
    }
    syncType: 'Scheduled'
  }
}

resource waitSection 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'WaitSection'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '3.0'
    scriptContent: 'start-sleep -Seconds 600'
    cleanupPreference: 'Always'
    retentionInterval: 'PT1H'
  }
  dependsOn: [
    kvRoleAssignment
  ]
}

resource pool 'Microsoft.DevCenter/projects/pools@2024-08-01-preview' = {
  dependsOn:[
    project, waitSection
  ]
  location: location
  name: '${project.name}/pool1'
  properties: {
    devBoxDefinitionType: 'Value'
    devBoxDefinitionName: '~Catalog~${catalogName}~courseimage'
    devBoxDefinition: {
      imageReference: {
        id: '${project.id}/images/~Catalog~${catalogName}~courseimage'
      }
      sku: {
        name: 'general_i_8c32gb256ssd_v2'
      }
    }
    networkConnectionName: networkConnectionName
    licenseType: 'Windows_Client'
    localAdministrator: 'Enabled'
    stopOnDisconnect: {
      status: 'Enabled'
      gracePeriodMinutes: 60
    }
    singleSignOnStatus: 'Enabled'
    displayName: 'pool1'
    virtualNetworkType: 'Unmanaged'
  }
}

