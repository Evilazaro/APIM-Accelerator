# Architecture Overview

The Azure API Management Accelerator follows Azure Landing Zone design principles to provide a secure, scalable, and maintainable API management platform.

## 🏗️ High-Level Architecture

```mermaid
graph TB
    subgraph "Azure Landing Zone Design Areas"
        subgraph "Identity & Access"
            MI[System Managed Identities]
            RBAC[RBAC Assignments]
            AAD[Azure Active Directory]
        end
        
        subgraph "Management & Monitoring"
            LA[Log Analytics Workspace]
            AI[Application Insights]
            SA[Storage Account]
            Diag[Diagnostic Settings]
        end
        
        subgraph "Governance"
            Tags[Resource Tagging]
            RG[Single Resource Group]
            Config[Centralized Configuration]
        end
    end
    
    subgraph "Core APIM Platform"
        APIM[API Management Service]
        DevPortal[Developer Portal]
        Workspaces[APIM Workspaces]
        Logger[App Insights Logger]
    end
    
    subgraph "API Inventory & Governance"
        APICenter[API Center Service]
        APIWorkspace[API Center Workspace]
        APISource[API Source Registration]
    end
    
    MI --> APIM
    LA --> APIM
    AI --> Logger
    SA --> Diag
    APIM --> APICenter
    AAD --> DevPortal
    APIM --> APISource
```

## 🎯 Design Principles

### Landing Zone Alignment
This accelerator implements all five Azure Landing Zone design areas:

| Design Area | Current Implementation | Benefits |
|-------------|----------------------|----------|
| **Identity & Access** | System-assigned managed identities, automated RBAC assignments | Secure, credential-free service authentication |
| **Network Topology** | Public by default, VNet integration configurable | Flexible deployment options (public/private) |
| **Security** | Diagnostic logging, managed identities, HTTPS by default | Defense in depth without complexity |
| **Management** | Log Analytics workspace, Application Insights integration | Comprehensive observability and monitoring |
| **Governance** | Consistent resource tagging, centralized configuration | Cost tracking and operational governance |

### Core Principles

#### 1. **Security by Default**
- All communications encrypted in transit
- Managed identities eliminate stored credentials
- Least-privilege access controls
- Network segmentation and isolation

#### 2. **Operational Excellence**
- Comprehensive logging and monitoring
- Automated diagnostics and alerting
- Infrastructure as Code (IaC)
- Consistent deployment patterns

#### 3. **Scalability & Performance**
- Horizontal scaling capabilities
- Regional deployment options
- Performance monitoring built-in
- Load balancing and traffic management

#### 4. **Cost Optimization**
- Resource right-sizing options
- Efficient monitoring configuration
- Tag-based cost allocation
- Environment-specific scaling

#### 5. **Reliability**
- Multi-zone deployment options
- Backup and disaster recovery ready
- Health monitoring and alerting
- Self-healing capabilities

## 🏢 Component Architecture

### Simplified Resource Group Structure

The accelerator uses a **single resource group** approach for simplified management while maintaining logical component separation through tagging and naming conventions.

```mermaid
graph TB
    subgraph "Single Resource Group"
        subgraph "Shared Infrastructure"
            LA[Log Analytics Workspace]
            AI[Application Insights]
            SA[Storage Account]
        end
        
        subgraph "Core Platform"
            APIM[API Management Service]
            DevPortal[Developer Portal Config]
            Workspaces[APIM Workspaces]
        end
        
        subgraph "API Inventory"
            APICenter[API Center Service]
            APIWorkspace[API Center Workspace]
            APISource[API Source Registration]
        end
    end
    
    LA --> APIM
    AI --> APIM
    SA --> APIM
    APIM --> APICenter
```

### Resource Organization Benefits
- **Simplified Management**: Single resource group reduces complexity
- **Clear Dependencies**: Resource dependencies are explicit and managed
- **Cost Efficiency**: Reduced resource group overhead
- **Deployment Simplicity**: Single scope for all related resources
- **Component Tagging**: Logical separation through consistent tagging strategy

## 🔧 Technical Architecture

### Shared Infrastructure Layer

#### Connectivity Architecture (Current Implementation)
```mermaid
graph TB
    subgraph "Public Deployment (Default)"
        Internet[Internet]
        APIM[API Management Service]
        DevPortal[Developer Portal]
    end
    
    subgraph "Optional VNet Integration"
        VNet[Virtual Network]
        Subnet[APIM Subnet]
        NSG[Network Security Group]
    end
    
    subgraph "Configurable Options"
        Internal[Internal VNet Mode]
        External[External VNet Mode]
        None[Public Mode - Default]
    end
    
    Internet --> APIM
    Internet --> DevPortal
    VNet -.-> APIM
    Subnet -.-> APIM
    NSG -.-> Subnet
```

**Note**: Networking components are configurable but not deployed by default. The accelerator supports public deployment (default) with optional VNet integration for private scenarios.

#### Identity & Access Management
```mermaid
graph LR
    subgraph "Azure AD"
        SP[Service Principal]
        Users[Users & Groups]
    end
    
    subgraph "Managed Identities"
        MSI[System Assigned]
        UMI[User Assigned]
    end
    
    subgraph "RBAC"
        Owner[Owner Role]
        Contributor[Contributor Role]
        Reader[Reader Role]
        Custom[Custom Roles]
    end
    
    SP --> RBAC
    MSI --> RBAC
    UMI --> RBAC
    Users --> RBAC
```

#### Security Architecture (Current Implementation)
```mermaid
graph TB
    subgraph "Identity Security"
        MSI[System Managed Identities]
        RBAC[Automated RBAC Assignments]
        AAD[Azure AD Integration]
    end
    
    subgraph "Data Security"
        HTTPS[HTTPS by Default]
        Encryption[Encryption in Transit]
        Diag[Diagnostic Logging]
    end
    
    subgraph "Access Control"
        Reader[Reader Role - APIM]
        APICenterReader[API Center Reader]
        APICenterContrib[API Center Contributor]
    end
    
    MSI --> RBAC
    RBAC --> Reader
    RBAC --> APICenterReader
    RBAC --> APICenterContrib
    AAD --> DevPortalAuth[Developer Portal Auth]
```

**Security Features**:
- **No Stored Secrets**: All authentication uses managed identities
- **Least Privilege**: Minimal required permissions automatically assigned
- **Comprehensive Logging**: All operations logged to Log Analytics
- **Default Encryption**: HTTPS enforced, data encrypted in transit

#### Monitoring & Observability
```mermaid
graph TB
    subgraph "Data Collection"
        Metrics[Azure Metrics]
        Logs[Azure Logs]
        Traces[Application Traces]
    end
    
    subgraph "Storage & Processing"
        LA[Log Analytics Workspace]
        Storage[Storage Account]
        AI[Application Insights]
    end
    
    subgraph "Visualization & Alerting"
        Dashboards[Azure Dashboards]
        Workbooks[Azure Workbooks]
        Alerts[Alert Rules]
    end
    
    Metrics --> LA
    Logs --> LA
    Traces --> AI
    LA --> Dashboards
    AI --> Dashboards
    LA --> Alerts
```

### Core Platform Layer

#### API Management Architecture
```mermaid
graph TB
    subgraph "API Management Service"
        Gateway[API Gateway]
        Management[Management API]
        Portal[Developer Portal]
        
        subgraph "Workspaces"
            WS1[Workspace 1]
            WSN[Additional Workspaces]
        end
        
        subgraph "Monitoring Integration"
            AILogger[App Insights Logger]
            Diagnostics[Diagnostic Settings]
        end
    end
    
    subgraph "External Integration"
        Backends[Backend Services]
        AAD[Azure AD Authentication]
        APICenter[API Center Integration]
    end
    
    Gateway --> Backends
    Management --> AAD
    Portal --> AAD
    AILogger --> ApplicationInsights[Application Insights]
    Diagnostics --> LogAnalytics[Log Analytics]
    APIM --> APICenter
```

### Inventory Management Layer

#### API Center Integration
```mermaid
graph TB
    subgraph "API Center"
        Catalog[API Catalog]
        Governance[API Governance]
        Discovery[API Discovery]
    end
    
    subgraph "APIM Integration"
        APIs[APIM APIs]
        Products[APIM Products]
        Subscriptions[APIM Subscriptions]
    end
    
    subgraph "External Sources"
        OpenAPI[OpenAPI Specs]
        Swagger[Swagger Docs]
        PostmanAPI[Postman Collections]
    end
    
    APIs --> Catalog
    Products --> Catalog
    OpenAPI --> Discovery
    Swagger --> Discovery
    PostmanAPI --> Discovery
    Catalog --> Governance
```

## 🔄 Data Flow Architecture

### Request Flow
```mermaid
sequenceDiagram
    participant Client
    participant APIM as API Management
    participant Backend
    participant Monitor as Monitoring
    
    Client->>APIM: API Request
    APIM->>APIM: Authentication
    APIM->>APIM: Policy Execution
    APIM->>Backend: Transformed Request
    Backend->>APIM: Response
    APIM->>APIM: Response Policies
    APIM->>Client: API Response
    APIM->>Monitor: Telemetry Data
```

### Monitoring Data Flow (Current Implementation)
```mermaid
graph LR
    subgraph "Data Sources"
        APIM[API Management]
        APICenter[API Center]
        LAW[Log Analytics Workspace]
        SA[Storage Account]
    end
    
    subgraph "Collection & Processing"
        DiagSettings[Diagnostic Settings]
        AILogger[App Insights Logger]
        Metrics[Azure Metrics]
    end
    
    subgraph "Storage & Analysis"
        LA[Log Analytics Workspace]
        AI[Application Insights]
        Storage[Storage Account Archive]
    end
    
    subgraph "Consumption"
        Portal[Azure Portal]
        Workbooks[Azure Workbooks]
        Alerts[Alert Rules]
        Queries[KQL Queries]
    end
    
    APIM --> DiagSettings
    APIM --> AILogger
    APICenter --> DiagSettings
    
    DiagSettings --> LA
    DiagSettings --> Storage
    AILogger --> AI
    Metrics --> AI
    
    LA --> Portal
    AI --> Portal
    LA --> Workbooks
    AI --> Workbooks
    LA --> Alerts
    LA --> Queries
```

## 🚀 Deployment Architecture

### Infrastructure as Code Structure
```
infra/
├── main.bicep                    # Subscription-level orchestration
├── main.parameters.json          # Optional parameters file
├── settings.yaml                 # Centralized configuration
└── azd-hooks/
    └── pre-provision.sh          # Pre-deployment automation

src/
├── shared/                       # Shared infrastructure components
│   ├── main.bicep               # Shared orchestration
│   ├── common-types.bicep       # Bicep type definitions
│   ├── constants.bicep          # Utility functions and constants
│   ├── monitoring/              # Monitoring infrastructure
│   │   ├── main.bicep          # Monitoring orchestration
│   │   ├── operational/
│   │   │   └── main.bicep      # Log Analytics + Storage
│   │   └── insights/
│   │       └── main.bicep      # Application Insights
│   └── networking/              # Network components (placeholder)
│       └── main.bicep
├── core/                         # Core APIM platform
│   ├── main.bicep               # Core platform orchestration
│   ├── apim.bicep               # API Management service
│   ├── developer-portal.bicep   # Developer portal configuration
│   └── workspaces.bicep         # APIM workspace management
└── inventory/                    # API inventory management
    └── main.bicep               # API Center integration
```

### Deployment Flow
```mermaid
graph TD
    Start[Start Deployment] --> Config[Load settings.yaml]
    Config --> Validate[Validate Templates]
    Validate --> RG[Create Resource Group]
    RG --> Shared[Deploy Shared Monitoring]
    Shared --> Core[Deploy APIM Platform]
    Core --> Inventory[Deploy API Center]
    Inventory --> Integration[Configure API Source]
    Integration --> Complete[Deployment Complete]
    
    Validate --> |Validation Fails| Error[Report Errors]
    Shared --> |Deployment Fails| Rollback[Rollback Changes]
    Core --> |Deployment Fails| Rollback
    Inventory --> |Deployment Fails| Rollback
```

## 🔗 Integration Patterns

### External System Integration
```mermaid
graph TB
    subgraph "External Systems"
        ERP[ERP Systems]
        CRM[CRM Systems]
        Legacy[Legacy Applications]
        SaaS[SaaS Applications]
    end
    
    subgraph "API Management"
        Gateway[API Gateway]
        Policies[API Policies]
        Transform[Data Transformation]
    end
    
    subgraph "Backend Services"
        Microservices[Microservices]
        Functions[Azure Functions]
        WebApps[Web Applications]
        Databases[Databases]
    end
    
    ERP --> Gateway
    CRM --> Gateway
    Legacy --> Gateway
    SaaS --> Gateway
    
    Gateway --> Policies
    Policies --> Transform
    Transform --> Microservices
    Transform --> Functions
    Transform --> WebApps
    Transform --> Databases
```

## 📊 Scalability Considerations

### Current Scaling Options

#### API Management Scaling
- **SKU Selection**: Developer (testing) → Premium (production)
- **Capacity Units**: Configurable scale units per environment
- **Workspace Organization**: Multiple workspaces for team isolation
- **Regional Deployment**: Deploy accelerator in multiple regions

#### Monitoring Scaling
- **Log Analytics**: PerGB2018 pricing scales with usage
- **Application Insights**: Automatic scaling with telemetry volume
- **Storage Account**: LRS for cost efficiency, upgrade to GRS if needed
- **Retention Policies**: Configure based on compliance requirements

#### Environment-Specific Scaling
```yaml
# Example scaling configurations
dev:
  apiManagement:
    sku: { name: "Developer", capacity: 1 }
    
staging:
  apiManagement:
    sku: { name: "Standard", capacity: 1 }
    
production:
  apiManagement:
    sku: { name: "Premium", capacity: 3 }
```

### Future Scaling Considerations
- **Multi-Region**: Deploy accelerator template in multiple Azure regions
- **VNet Integration**: Add networking module for enterprise connectivity
- **Advanced Security**: Integrate Key Vault for certificate management
- **CI/CD Integration**: Add Azure DevOps or GitHub Actions templates

## 🎯 Next Steps

To dive deeper into specific implementation details:

- **[Settings Schema Reference](../reference/settings-schema.md)** - Complete configuration reference
- **[Bicep Module Reference](../reference/bicep-modules.md)** - Technical implementation details
- **[Azure Resources Reference](../reference/azure-resources.md)** - Complete resource inventory
- **[RBAC & Permissions Guide](../reference/permissions.md)** - Security configuration details

---

**Related Documentation:**
- [Getting Started](../getting-started/) - Quick deployment guide
- [Configuration Guide](../user-guide/configuration.md) - Detailed configuration
- [Developer Guide](../developer-guide/) - Customization and extension