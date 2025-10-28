# Architecture Overview

The Azure API Management Landing Zone Accelerator follows Azure Landing Zone design principles to provide a secure, scalable, and maintainable API management platform.

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

### Resource Group Organization

```mermaid
graph LR
    subgraph "Subscription"
        RG1[apim-plat-connectivity-rg]
        RG2[apim-plat-identity-rg]
        RG3[apim-plat-security-rg]
        RG4[apim-plat-monitoring-rg]
        RG5[apim-plat-rg]
        RG6[apim-plat-inventory-rg]
    end
    
    RG1 --> Networking[VNet, Subnets, NSGs]
    RG2 --> Identity[Managed Identities]
    RG3 --> Security[Key Vault]
    RG4 --> Monitoring[Log Analytics, App Insights]
    RG5 --> Core[API Management]
    RG6 --> Inventory[API Center]
```

### Resource Separation Benefits
- **Blast Radius Limitation**: Issues in one component don't affect others
- **RBAC Granularity**: Different teams can have different access levels
- **Cost Allocation**: Clear cost attribution by component
- **Lifecycle Management**: Independent lifecycle for different components

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
        Management[Management Plane]
        Portal[Developer Portal]
        
        subgraph "Workspaces"
            WS1[Workspace 1]
            WS2[Workspace 2]
            WSN[Workspace N]
        end
    end
    
    subgraph "Integration"
        Backend1[Backend Service 1]
        Backend2[Backend Service 2]
        BackendN[Backend Service N]
    end
    
    subgraph "Authentication"
        AAD[Azure AD]
        OAuth[OAuth Providers]
        JWT[JWT Validation]
    end
    
    Gateway --> Backend1
    Gateway --> Backend2
    Gateway --> BackendN
    Management --> AAD
    Portal --> OAuth
    Gateway --> JWT
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
├── main.bicep                 # Orchestration template
├── settings.yaml             # Configuration file
└── azd-hooks/
    └── pre-provision.sh      # Pre-deployment scripts

src/
├── shared/                   # Shared infrastructure
│   ├── monitoring/          # Log Analytics, App Insights
│   ├── constants.bicep      # Reusable constants
│   └── common-types.bicep   # Type definitions
├── core/                    # Core APIM platform
│   ├── main.bicep          # Core orchestration
│   ├── apim.bicep          # APIM service
│   ├── developer-portal.bicep
│   └── workspaces.bicep
└── inventory/              # API Center integration
    └── main.bicep
```

### Deployment Flow
```mermaid
graph TD
    Start[Start Deployment] --> Config[Load Configuration]
    Config --> Validate[Validate Templates]
    Validate --> RG[Create Resource Groups]
    RG --> Shared[Deploy Shared Infrastructure]
    Shared --> Core[Deploy Core Platform]
    Core --> Inventory[Deploy API Center]
    Inventory --> Configure[Configure Integration]
    Configure --> Test[Validation Tests]
    Test --> Complete[Deployment Complete]
    
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