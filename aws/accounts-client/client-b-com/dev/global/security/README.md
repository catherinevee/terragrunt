# Client B - Global Security Infrastructure (Development)

## 🛡️ **Comprehensive AWS Security Architecture**

This directory contains a complete, enterprise-grade AWS security infrastructure for Client B's development environment. The solution leverages modules from [Catherine Vee's GitHub repository](https://github.com/catherinevee) and implements industry best practices for cloud security, compliance, and threat detection.

## 📁 **Security Module Structure**

```
security/
├── terragrunt.hcl                    # Main security orchestration
├── README.md                        # This documentation
├── iam/                             # Identity & Access Management Security
│   └── terragrunt.hcl
├── kms/                             # Key Management Service Security
│   └── terragrunt.hcl
├── cloudtrail/                      # Audit Logging & Compliance
│   └── terragrunt.hcl
├── config/                          # AWS Config Compliance Monitoring
│   └── terragrunt.hcl
├── guardduty/                       # Threat Detection & Response
│   └── terragrunt.hcl
└── securityhub/                     # Security Findings Aggregation
    └── terragrunt.hcl
```

## 🧩 **Security Components Overview**

### **🔐 Identity & Access Management (IAM) Security**
- **Security-focused IAM policies** with least privilege principles
- **Data protection policies** enforcing encryption requirements
- **Compliance policies** for audit and governance
- **Security administrator roles** with appropriate permissions
- **Compliance auditor roles** for monitoring and reporting

### **🔑 Key Management Service (KMS) Security**
- **Global encryption keys** for cross-service encryption
- **Service-specific keys** for CloudTrail, Config, GuardDuty, Security Hub
- **Secrets management keys** for sensitive data protection
- **Key policies** with strict access controls
- **Key rotation** and lifecycle management

### **📋 CloudTrail Security**
- **Multi-region audit logging** for comprehensive visibility
- **Advanced event selectors** for sensitive data monitoring
- **CloudWatch integration** with metric filters and alarms
- **S3 bucket encryption** with lifecycle policies
- **Real-time monitoring** of security events

### **⚖️ AWS Config Security**
- **Compliance monitoring** across all AWS resources
- **Automated remediation** for security violations
- **Configuration rules** for encryption, access controls, and best practices
- **SNS notifications** for compliance violations
- **Long-term audit storage** with lifecycle management

### **🛡️ GuardDuty Security**
- **Threat detection** across multiple data sources
- **Malware protection** with EBS volume scanning
- **S3 protection** for data exfiltration detection
- **EKS protection** for container security
- **Custom threat lists** for organization-specific threats
- **Automated response** with CloudWatch Events

### **🔍 Security Hub Security**
- **Centralized security findings** from multiple AWS services
- **Security standards** (CIS, AWS Foundational Security)
- **Compliance frameworks** (GDPR, ISO27001, SOC2)
- **Product integrations** with GuardDuty, Inspector, Macie
- **Custom insights** for security analysis
- **Automated workflows** for incident response

## 🔗 **Dependencies & Deployment Order**

### **Phase 1: Foundation Security (Deploy First)**
1. **KMS** - Encryption keys and policies
2. **IAM** - Security roles, policies, and access controls

### **Phase 2: Monitoring & Compliance (Deploy Second)**
3. **CloudTrail** - Audit logging and event monitoring
4. **AWS Config** - Compliance monitoring and remediation

### **Phase 3: Threat Detection (Deploy Third)**
5. **GuardDuty** - Threat detection and response
6. **Security Hub** - Centralized security management

## 🚀 **Deployment Commands**

```bash
# Navigate to the security directory
cd terragrunt/aws/accounts-client/client-b-com/dev/global/security

# Deploy all security modules in dependency order
terragrunt run-all apply

# Deploy specific security modules
terragrunt apply --terragrunt-working-dir kms
terragrunt apply --terragrunt-working-dir iam
terragrunt apply --terragrunt-working-dir cloudtrail
terragrunt apply --terragrunt-working-dir config
terragrunt apply --terragrunt-working-dir guardduty
terragrunt apply --terragrunt-working-dir securityhub

# Plan security changes
terragrunt run-all plan

# Destroy security modules (in reverse order)
terragrunt destroy --terragrunt-working-dir securityhub
terragrunt destroy --terragrunt-working-dir guardduty
terragrunt destroy --terragrunt-working-dir config
terragrunt destroy --terragrunt-working-dir cloudtrail
terragrunt destroy --terragrunt-working-dir iam
terragrunt destroy --terragrunt-working-dir kms
```

## 🏛️ **Security Architecture**

### **Defense in Depth Strategy**
- **Perimeter Security**: IAM policies and access controls
- **Data Security**: KMS encryption and key management
- **Monitoring**: CloudTrail audit logging and AWS Config compliance
- **Threat Detection**: GuardDuty threat intelligence
- **Centralized Management**: Security Hub findings aggregation

### **Compliance Framework**
- **GDPR**: Data protection and privacy controls
- **ISO27001**: Information security management
- **SOC2**: Security, availability, and confidentiality
- **CIS AWS Foundations**: Security best practices
- **AWS Well-Architected**: Security pillar implementation

### **Security Controls**
- **Access Control**: Least privilege IAM policies
- **Encryption**: KMS-managed keys for all data
- **Audit Logging**: Comprehensive CloudTrail monitoring
- **Compliance Monitoring**: AWS Config rule enforcement
- **Threat Detection**: GuardDuty machine learning
- **Incident Response**: Security Hub automated workflows

## 📊 **Monitoring & Alerting**

### **CloudWatch Alarms**
- **High severity findings** from GuardDuty and Security Hub
- **Compliance violations** from AWS Config
- **Unauthorized access** attempts from CloudTrail
- **Key usage anomalies** from KMS

### **SNS Notifications**
- **Security team** for immediate response
- **DevOps team** for operational awareness
- **Compliance team** for audit requirements
- **SOC team** for incident management

### **Dashboard & Reporting**
- **Security Hub insights** for trend analysis
- **CloudWatch dashboards** for real-time monitoring
- **Compliance reports** for audit preparation
- **Threat intelligence** feeds for proactive defense

## 🔧 **Configuration Details**

### **Environment-Specific Settings**
- **Development environment** optimizations for cost and flexibility
- **Reduced retention periods** for development workloads
- **Automated remediation** for common security issues
- **Integration with development workflows** and CI/CD pipelines

### **Security Hardening**
- **KMS encryption** for all data at rest and in transit
- **IAM password policies** with complexity requirements
- **MFA enforcement** for privileged accounts
- **Network security** with VPC and security groups
- **Resource tagging** for security classification

### **Compliance Features**
- **Automated compliance checks** with AWS Config rules
- **Audit trail preservation** with CloudTrail logging
- **Data residency controls** for EU compliance
- **Privacy protection** with encryption and access controls

## 🔍 **Troubleshooting**

### **Common Security Issues**

1. **IAM Permission Errors**
   ```bash
   # Check IAM role permissions
   aws iam get-role --role-name ClientB-Dev-SecurityAdminRole
   aws iam list-attached-role-policies --role-name ClientB-Dev-SecurityAdminRole
   ```

2. **KMS Key Access Issues**
   ```bash
   # Verify KMS key policies
   aws kms describe-key --key-id alias/client-b-dev-global-encryption
   aws kms get-key-policy --key-id <key-id> --policy-name default
   ```

3. **CloudTrail Logging Issues**
   ```bash
   # Check CloudTrail status
   aws cloudtrail describe-trails --trail-name-list client-b-dev-cloudtrail
   aws cloudtrail get-trail-status --name client-b-dev-cloudtrail
   ```

4. **GuardDuty Finding Issues**
   ```bash
   # Verify GuardDuty detector
   aws guardduty list-detectors
   aws guardduty get-detector --detector-id <detector-id>
   ```

5. **Security Hub Integration Issues**
   ```bash
   # Check Security Hub status
   aws securityhub describe-hub
   aws securityhub list-enabled-standards
   ```

### **Useful Security Commands**

```bash
# Check security module status
terragrunt run-all show

# Validate security configurations
terragrunt run-all validate-inputs

# Check security dependencies
terragrunt graph

# View security outputs
terragrunt output --terragrunt-working-dir kms
terragrunt output --terragrunt-working-dir iam
```

## 📋 **Pre-deployment Security Checklist**

- [ ] AWS credentials configured with appropriate permissions
- [ ] S3 backend bucket exists with encryption enabled
- [ ] DynamoDB table for state locking exists
- [ ] Required IAM permissions granted for security services
- [ ] Account and region configurations verified
- [ ] KMS key policies reviewed and approved
- [ ] Security group rules validated
- [ ] Compliance requirements documented
- [ ] Incident response procedures defined
- [ ] Security team contacts configured

## 🔄 **Security Maintenance & Updates**

### **Regular Security Tasks**
- **Daily**: Review GuardDuty findings and Security Hub alerts
- **Weekly**: Analyze CloudTrail logs for suspicious activity
- **Monthly**: Update security policies and compliance rules
- **Quarterly**: Review and update IAM permissions
- **Annually**: Conduct security assessments and penetration testing

### **Security Updates**
- **Module versions**: Pinned to specific versions for stability
- **Security patches**: Applied through automated processes
- **Compliance updates**: Integrated as new requirements emerge
- **Threat intelligence**: Updated with latest threat feeds

## 📞 **Security Support & Contacts**

- **Security Team**: security@clientb.com
- **DevOps Team**: devops@clientb.com
- **Compliance Team**: compliance@clientb.com
- **SOC Team**: soc@clientb.com
- **Security Lead**: security-lead@clientb.com

## 📚 **Additional Security Resources**

- [AWS Security Best Practices](https://aws.amazon.com/security/security-learning/)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services/)
- [AWS Well-Architected Security Pillar](https://aws.amazon.com/architecture/well-architected/)
- [AWS Security Documentation](https://docs.aws.amazon.com/security/)
- [Catherine Vee's Security Modules](https://github.com/catherinevee)

## 🔒 **Security Compliance**

This security infrastructure is designed to meet the following compliance requirements:

- **GDPR**: Data protection and privacy controls
- **ISO27001**: Information security management system
- **SOC2**: Security, availability, and confidentiality
- **CIS AWS Foundations**: Security best practices
- **AWS Well-Architected**: Security pillar requirements

---

**Last Updated**: January 2025  
**Version**: 1.0.0  
**Environment**: Development  
**Security Level**: High  
**Compliance**: GDPR, ISO27001, SOC2, CIS 