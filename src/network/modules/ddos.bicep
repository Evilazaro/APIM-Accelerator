@description('Name of the DDoS Protection Plan')
param name string

@description('Location of the DDoS Protection Plan')
param location string

@description('Tags for the DDoS Protection Plan')
param tags object 

@description('DDoS Protection Plan resource')
resource ddosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2024-07-01' = {
  name: name
  location: location
  tags: tags
}

@description('DDoS Protection Plan ID output')
output DDOS_PROTECTION_PLAN_ID string = ddosProtectionPlan.id
