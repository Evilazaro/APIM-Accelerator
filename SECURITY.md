# Security Policy

## Supported Versions

We provide security updates for the following versions of the Azure API Management Accelerator:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security vulnerability in this project, please report it responsibly by following these steps:

### How to Report

1. **Do NOT create a public GitHub issue** for security vulnerabilities
2. **Email us directly** at [evilazaro@gmail.com](mailto:evilazaro@gmail.com) with the subject line: "SECURITY: Azure APIM Accelerator Vulnerability Report"
3. **Include the following information**:
   - Description of the vulnerability
   - Steps to reproduce the issue
   - Potential impact assessment
   - Suggested fix (if available)
   - Your contact information

### What to Expect

- **Acknowledgment**: We will acknowledge receipt of your report within 2 business days
- **Initial Assessment**: We will provide an initial assessment within 5 business days
- **Status Updates**: We will keep you informed of our progress throughout the investigation
- **Resolution Timeline**: We aim to resolve critical security issues within 30 days
- **Disclosure**: We will coordinate with you on the timing of public disclosure

### Vulnerability Assessment Criteria

We use the following criteria to assess vulnerability severity:

#### Critical
- Remote code execution
- Privilege escalation to subscription owner
- Exposure of highly sensitive data (credentials, keys)
- Complete bypass of authentication/authorization

#### High
- Significant data exposure
- Local privilege escalation
- Denial of service with significant impact
- Authentication bypass

#### Medium
- Limited data exposure
- Minor privilege escalation
- Information disclosure
- Configuration weaknesses

#### Low
- Minor information disclosure
- Low-impact denial of service
- Non-security configuration issues

## Security Best Practices for Users

When using this accelerator, please follow these security best practices:

### Deployment Security
- **Never commit secrets** to version control
- **Use managed identities** instead of service principals where possible
- **Enable diagnostic logging** for all resources
- **Implement least-privilege access** principles
- **Regularly review role assignments** and permissions

### Configuration Security
- **Use private endpoints** where possible
- **Disable public network access** for sensitive resources
- **Enable network security groups** with restrictive rules
- **Use Azure Key Vault** for all secrets and certificates
- **Implement proper tagging** for security classification

### Operational Security
- **Monitor access logs** and audit trails
- **Set up security alerts** for suspicious activities
- **Regularly update** to the latest version
- **Perform security assessments** of your deployment
- **Follow Azure Security Benchmark** recommendations

### Template Security
- **Review all Bicep templates** before deployment
- **Validate parameter values** and constraints
- **Use secure parameter handling** with `@secure()` decorator
- **Test in non-production** environments first
- **Implement change approval** processes

## Security Features

This accelerator includes several security features:

### Built-in Security Controls
- **Managed Identity Integration**: Eliminates the need for stored credentials
- **RBAC Configuration**: Implements least-privilege access patterns
- **Network Security**: Supports private networking and NSGs
- **Audit Logging**: Comprehensive diagnostic settings for all resources
- **Secret Management**: Integration with Azure Key Vault

### Security Monitoring
- **Application Insights**: Application performance and security monitoring
- **Log Analytics**: Centralized logging and security event analysis
- **Diagnostic Settings**: Comprehensive audit trails
- **Alert Rules**: Proactive security monitoring (user-configurable)

## Common Security Considerations

### Azure API Management Security
- **Subscription Keys**: Manage API access with subscription keys
- **OAuth/JWT Validation**: Implement proper token validation
- **Rate Limiting**: Protect against abuse and DoS attacks
- **IP Filtering**: Restrict access by IP address when appropriate
- **TLS Configuration**: Ensure proper TLS/SSL configuration

### Infrastructure Security
- **Network Isolation**: Use VNets and private endpoints
- **Key Management**: Secure key rotation and management
- **Access Controls**: Implement proper RBAC and conditional access
- **Monitoring**: Continuous security monitoring and alerting

## Security Updates

We will notify users of security updates through:
- **GitHub Security Advisories**: For vulnerability disclosures
- **Release Notes**: For security-related fixes
- **Email Notifications**: For critical security updates (if subscribed)

## Compliance and Standards

This accelerator is designed to support compliance with:
- **Azure Security Benchmark**
- **Azure Landing Zone Security Guidelines**
- **GDPR** (where applicable)
- **SOC 2** (security controls)
- **ISO 27001** (information security management)

## Third-Party Dependencies

We regularly review and update third-party dependencies for security vulnerabilities. Current dependencies include:
- **Azure Resource Manager Templates**: Microsoft-maintained
- **Bicep Language**: Microsoft-maintained
- **Azure CLI**: Microsoft-maintained

## Security Contacts

For security-related inquiries:
- **Email**: [evilazaro@gmail.com](mailto:evilazaro@gmail.com)
- **Response Time**: 2 business days for acknowledgment
- **Escalation**: Include "URGENT SECURITY" in subject line for critical issues

## Bug Bounty Program

Currently, we do not have a formal bug bounty program. However, we greatly appreciate responsible disclosure of security vulnerabilities and will acknowledge contributors in our security advisories (with permission).

## Legal

By reporting security vulnerabilities to us, you agree to:
- Work with us to resolve the issue responsibly
- Not publicly disclose the vulnerability until we have had reasonable time to address it
- Not exploit the vulnerability for malicious purposes
- Provide us with reasonable time to investigate and address the issue

We commit to:
- Acknowledge your report promptly
- Keep you informed of our progress
- Credit you for the discovery (if desired and legal)
- Not take legal action against you for responsible disclosure

---

Thank you for helping us keep the Azure API Management Accelerator secure!