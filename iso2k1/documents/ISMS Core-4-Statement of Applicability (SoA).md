# **Statement of Applicability (SoA)**  

---

**Document Version:** 1.0  
**Date:** [Insert Date]  
**Owner:** [ISMS Manager or Responsible Person]  
**Approved By:** [Senior Management]  

---

## **1. Purpose**  
The **Statement of Applicability (SoA)** is a key document in the **ISO 27001 Information Security Management System (ISMS)** that provides:  

- A **list of applicable security controls** from **Annex A of ISO 27001:2022**  
- Justification for inclusion/exclusion of each control  
- A reference to relevant policies, procedures, and security measures implemented  

This SoA is aligned with **[Company Name]’s Microsoft Azure environment**, which serves as a **landing zone for software development, deployment, and customer delivery**.  

---

## **2. Scope**  
This SoA applies to the **Azure tenant**, including:  

- **Azure-hosted infrastructure** (VMs, databases, storage, networking)  
- **Cloud identity and access management (IAM)**  
- **DevSecOps and secure software development lifecycle (SDLC)**  
- **Security controls for customer-facing applications**  

Excluded: On-premise IT, customer-managed environments, and end-user devices.  

---

## **3. Statement of Applicability Table**  

The table below maps **Annex A controls** to their applicability, justification, and related security policies.  

| **Control No.** | **Control Name** | **Applicable?** | **Justification** | **Reference Policy/Procedure** |
|----------------|------------------|----------------|-------------------|-------------------------------|
| **A.5** | Information Security Policies | ✅ Yes | Required for ISO 27001 compliance | Information Security Policy |
| **A.6** | Organization of Information Security | ✅ Yes | Defines roles, responsibilities, and governance | ISMS Governance Document |
| **A.7** | Human Resource Security | ✅ Yes | Ensures employees comply with security policies | Employee Security Policy |
| **A.8** | Asset Management | ✅ Yes | Ensures protection of Azure cloud assets | Asset Management Policy |
| **A.9** | Access Control | ✅ Yes | Manages Azure IAM, RBAC, and MFA policies | Access Control Policy |
| **A.10** | Cryptography | ✅ Yes | Data in transit and at rest must be encrypted | Cryptographic Policy |
| **A.11** | Physical Security | ❌ No | Physical security is managed by Microsoft Azure | N/A |
| **A.12** | Operations Security | ✅ Yes | Defines security for Azure VMs, networks, and logging | Cloud Security Policy |
| **A.13** | Communications Security | ✅ Yes | Ensures secure API communications and data transfers | Data Protection Policy |
| **A.14** | System Acquisition, Development, and Maintenance | ✅ Yes | Secure SDLC and DevSecOps in Azure | Secure Software Development Policy |
| **A.15** | Supplier Relationships | ✅ Yes | Security of third-party cloud service providers | Supplier and Third-Party Security Policy |
| **A.16** | Incident Management | ✅ Yes | Incident detection and response for Azure-based risks | Incident Management Procedure |
| **A.17** | Business Continuity | ✅ Yes | Ensures Azure-hosted services remain operational | Business Continuity & DR Plan |
| **A.18** | Compliance | ✅ Yes | Ensures regulatory compliance (ISO 27001, GDPR) | Compliance Requirements Document |

---

## **4. Justification for Excluded Controls**  

| **Control No.** | **Control Name** | **Reason for Exclusion** |
|----------------|------------------|--------------------------|
| **A.11** | Physical Security | Microsoft Azure manages all physical security controls in its data centers. |
| **A.14.2.7** | Outsourced Development | All software development is performed in-house; third-party developers are not used. |
| **A.17.2** | Redundancies | Azure provides high-availability and failover mechanisms, so no additional redundancy is required. |

---

## **5. Review & Approval**  

| **Prepared By**    | [Name] | [Title] | [Date] |
|--------------------|--------|---------|--------|
| **Reviewed By**   | [Name] | [Title] | [Date] |
| **Approved By**   | [Name] | [Title] | [Date] |

---

This **Statement of Applicability (SoA)** ensures that [Company Name] applies **ISO 27001 security controls** relevant to its **Azure cloud environment** while maintaining compliance with industry standards.  
