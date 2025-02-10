### **ISO 27001 ISMS Scope Document**  

---

**Document Version:** 1.0  
**Date:** [Date]   
**Owner:** [ISMS Manager or Responsible Person]  
**Approved By:** [Senior Management]  

---

### **1. Purpose**  
This document defines the scope of the Information Security Management System (ISMS) for [Company Name] in accordance with **ISO 27001** requirements. It establishes the boundaries and applicability of information security controls within the organization, ensuring that security risks related to the **Azure tenant and its use as a landing zone for application development and deployment** are effectively managed.  

---

### **2. Scope Statement**  
The scope of the ISMS at [Company Name] covers the **Microsoft Azure tenant** used as a **landing zone** for the development, deployment, and delivery of company-developed applications to customers. The scope includes:  

- **Azure-hosted infrastructure**, including virtual machines, databases, storage, networking, and security services used to support software development and deployment.  
- **Cloud-based application development and delivery processes** managed by the company.  
- **Security controls** implemented within the Azure environment to protect the confidentiality, integrity, and availability of data and applications.  
- **People, processes, and technology** involved in managing and maintaining security within the Azure tenant.  

**Out of Scope:**  
- **On-premise IT infrastructure**, except where it interfaces with the Azure environment.  
- **Customer-controlled environments** where the company has no direct management responsibility.  
- **End-user devices** used by customers to access the deployed applications.  

---

### **3. Organizational Context**  
[Company Name] is a **construction component manufacturing company** that develops software solutions hosted in **Microsoft Azure**. The organization provides software to clients, leveraging Azure’s infrastructure and services to ensure scalability, security, and compliance.  

- The ISMS ensures that security risks related to Azure-hosted applications and data are **systematically identified, assessed, and mitigated**.  
- The ISMS aligns with legal, regulatory, and contractual obligations, including **ISO 27001, GDPR, and industry best practices**.  
- The ISMS is maintained and continually improved to support business objectives and customer trust.  

---

### **4. ISMS Boundaries**  
The ISMS includes the following:  

| **Category**            | **In Scope**                         | **Out of Scope**                       |
|-------------------------|------------------------------------|----------------------------------------|
| **Cloud Environment**   | Microsoft Azure Tenant             | Other cloud providers (AWS, GCP)      |
| **Infrastructure**      | Azure-hosted VMs, databases, networking | On-premise IT infrastructure         |
| **Software Development** | CI/CD pipelines, DevSecOps, secure coding | Customer-managed integrations        |
| **Access Management**   | Identity and Access Management (IAM) in Azure | Local workstation logins             |
| **Security Controls**   | Firewalls, encryption, logging, vulnerability management in Azure | Security of customer-owned devices   |

---

### **5. Relevant Stakeholders**  
The ISMS scope involves the following stakeholders:  

- **Executive Management** – Provides leadership and oversight of the ISMS.  
- **IT & Security Teams** – Responsible for implementing security measures in Azure.  
- **Development Teams** – Ensures secure coding and deployment of applications.  
- **Customers** – Consumers of the cloud-hosted applications.  
- **Regulatory Authorities & Auditors** – Ensuring compliance with security and privacy regulations.  

---

### **6. Compliance and Regulatory Considerations**  
The ISMS considers the following compliance requirements:  

- **ISO/IEC 27001:2022** – Information Security Management System  
- **GDPR (General Data Protection Regulation)** – If handling EU customer data  
- **NIST Cybersecurity Framework** – Best practices for cloud security  
- **Microsoft Azure Security Benchmarks** – Aligning with Microsoft’s security best practices  

---

### **7. ISMS Governance and Maintenance**  
The ISMS scope is reviewed **annually** or upon significant changes in:  

- The **Azure infrastructure** (e.g., adoption of new services or changes in deployment models).  
- **Business processes** affecting cloud security.  
- **Regulatory or compliance requirements**.  

The ISMS is maintained by the **Information Security Team** and approved by **senior management**.  

---

### **8. Approval and Review**  

**Document** | [Name] | [Title] | [Date]
|--------------------|--------|---------|--------|
| **Prepared By**    | [Name] | [Title] | [Date] |
| **Reviewed By**   | [Name] | [Title] | [Date] |
| **Approved By**   | [Name] | [Title] | [Date] |

---
