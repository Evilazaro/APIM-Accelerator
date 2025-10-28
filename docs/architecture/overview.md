# Architecture Overview

The Azure API Management Accelerator follows Azure Landing Zone design principles to provide a secure, scalable, and maintainable API management platform.

## 🏗️ High-Level Architecture

```mermaid
graph TB
    subgraph "Azure Landing Zone"
        subgraph "Connectivity"
            VNet[Virtual Network]
            NSG[Network Security Groups]
            PE[Private Endpoints]
        end
        
        subgraph "Identity"
            MI[Managed Identities]
            RBAC[Role Assignments]
            AAD[Azure Active Directory]
        end
        
        subgraph "Security"
            KV[Key Vault]
            Policies[Security Policies]
        end
        
        subgraph "Management"
            LA[Log Analytics]
            AI[Application Insights]
            Monitor[Azure Monitor]
        end
        
        subgraph "Governance"
            Tags[Resource Tags]
            RG[Resource Groups]
            Compliance[Policy Compliance]
        end
    end
    
    subgraph "Core Platform"
        APIM[API Management]
        DevPortal[Developer Portal]
        Workspaces[Workspaces]
    end
    
    subgraph "Inventory"
        APICenter[API Center]
        Catalog[API Catalog]
    end
    
    VNet --> APIM
    MI --> APIM
    KV --> APIM
    LA --> APIM
    AI --> APIM
    APIM --> APICenter
    AAD --> DevPortal
```

## 🎯 Design Principles

### Landing Zone Alignment
This accelerator implements all five Azure Landing Zone design areas:

| Design Area | Implementation | Benefits |
|-------------|----------------|----------|
| **Identity & Access** | Managed identities, RBAC | Secure, credential-free access |
| **Network Topology** | VNet integration, private endpoints | Network isolation and security |
| **Security** | Key Vault, NSGs, monitoring | Defense in depth |
| **Management** | Centralized logging and monitoring | Operational excellence |
| **Governance** | Resource tagging, policy compliance | Cost management and compliance |

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

#### Connectivity Components
```mermaid
graph TB
    subgraph "Virtual Network"
        subgraph "APIM Subnet"
            APIM[API Management]
        end
        
        subgraph "App Gateway Subnet"
            AGW[Application Gateway]
        end
        
        subgraph "Private Endpoint Subnet"
            PE1[KV Private Endpoint]
            PE2[Storage Private Endpoint]
        end
    end
    
    NSG1[APIM NSG] --> APIM
    NSG2[AGW NSG] --> AGW
    NSG3[PE NSG] --> PE1
    NSG3 --> PE2
```

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

#### Security Layer
```mermaid
graph TB
    subgraph "Key Vault"
        Secrets[Secrets]
        Keys[Keys]
        Certs[Certificates]
    end
    
    subgraph "Network Security"
        NSGs[Network Security Groups]
        PE[Private Endpoints]
        FW[Firewall Rules]
    end
    
    subgraph "Access Control"
        RBAC[Role-Based Access]
        Policies[Azure Policies]
        CAP[Conditional Access]
    end
```

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

### Monitoring Data Flow
```mermaid
graph LR
    subgraph "Data Sources"
        APIM[API Management]
        KV[Key Vault]
        VNet[Virtual Network]
        NSG[Network Security Groups]
    end
    
    subgraph "Collection"
        Diag[Diagnostic Settings]
        Metrics[Azure Metrics]
    end
    
    subgraph "Storage"
        LA[Log Analytics]
        Storage[Storage Account]
        AI[Application Insights]
    end
    
    subgraph "Consumption"
        Dashboards[Dashboards]
        Alerts[Alerts]
        Reports[Reports]
    end
    
    APIM --> Diag
    KV --> Diag
    VNet --> Diag
    NSG --> Diag
    
    Diag --> LA
    Diag --> Storage
    Metrics --> AI
    
    LA --> Dashboards
    AI --> Dashboards
    LA --> Alerts
    AI --> Alerts
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

### Horizontal Scaling
- **API Management Units**: Scale processing capacity
- **Regional Deployment**: Multi-region for global reach
- **Workspace Isolation**: Separate environments and teams
- **Backend Integration**: Load balancing to backend services

### Vertical Scaling
- **SKU Tiers**: Basic → Standard → Premium
- **Feature Scaling**: Add capabilities as needed
- **Storage Scaling**: Increase log retention and storage
- **Monitoring Scaling**: Enhanced metrics and alerting

## 🎯 Next Steps

To dive deeper into specific architectural components:

- **[Landing Zone Alignment](landing-zones.md)** - Detailed LZ mapping
- **[Component Architecture](components.md)** - Individual component details
- **[Security Model](security.md)** - Security architecture deep dive
- **[Network Design](networking.md)** - Network topology details

---

**Related Documentation:**
- [Getting Started](../getting-started/) - Quick deployment guide
- [Configuration Guide](../user-guide/configuration.md) - Detailed configuration
- [Developer Guide](../developer-guide/) - Customization and extension