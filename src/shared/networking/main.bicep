// Optimized: Parameterize hardcoded values
param name string = 'vnet'
param location string = 'eastus'

// Optimized: Variables for configuration
var extendedLocationConfig = {}

resource virtualNetwork 'Microsoft.ScVmm/virtualNetworks@2025-03-13' = {
  name: name
  location: location
  extendedLocation: extendedLocationConfig
}
