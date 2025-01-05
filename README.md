
# Deploy Dev Box Service with team customization image

az bicep build --file .\main.bicep --outfile azuredeploy.json

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjacwu%2Fdevbox-teamcustomization-template%2Frefs%2Fheads%2Fmain%2Fazuredeploy.json)


This template provides a way to deploy a Dev Box service with team customization image incluing Dev Center, Dev box Project, Dev box Definition, Dev box pool, Network connection and Virtual Netowrk.

If you're new to **Dev Box**, see:

- [Microsoft Dev Box Documentation](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)
- [Quickstarts: Microsoft Dev Box](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-configure-dev-box-service?tabs=AzureADJoin)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

`Tags: Devcenter, Dev Box, ARM Template, Microsoft.DevCenter/devcenters`
