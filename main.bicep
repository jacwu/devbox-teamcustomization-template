@description('The name of the course')
@minLength(3)
@maxLength(12)
param projectName string = 'course'

@description('The github token to fetch image definition')
param githubToken string = 'github token'


var project = replace(projectName, ' ', '')
var vnetAddressPrefixes = '10.4.0.0/16'
var subnetAddressPrefixes = '10.4.0.0/16'
var suffix = '${project}-${take(guid(project), 4)}'
var xjtlu = suffix
var ncName = 'nc-${xjtlu}'
var devcenterName = 'dc-${xjtlu}'
var vnetName = 'vnet-${xjtlu}'
var subnetName = 'subnet-${xjtlu}'
var keyvaultName = 'kv-${xjtlu}'
var catalogName = 'catalog-${suffix}'
var location = 'eastasia'

module vnet 'modules/vnet.bicep' = {
  name: 'vnet'
  params: {
    location: location
    vnetAddressPrefixes: vnetAddressPrefixes
    vnetName: vnetName
    subnetAddressPrefixes: subnetAddressPrefixes
    subnetName: subnetName
  }
  
}

module devcenter 'modules/devcenter.bicep' = {
  name: 'devcenter'
  params: {
    location: location
    devcenterName: devcenterName
    subnetId: vnet.outputs.subnetId
    networkConnectionName: ncName
    projectName: project
    projectDescription: projectName
    keyVaultName: keyvaultName
    catalogName: catalogName
  }
}


