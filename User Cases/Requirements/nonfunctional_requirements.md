# 4ThePlot Non-Functional Requirements

| Req# | Requirement | Comments | Priority | Date | Reviewed/Approved |
| :--- | :--- | :--- | :---: | :---: | :--- |
| NFR_01 | 4ThePlot shall return standard user actions and page responses within 3 seconds for at least 95% of requests. | This target applies to common operations such as login, feed load, and event detail access. | 1 | 03/04/2026 | Ronad Lamani / Angjelina Zenunaj |
| NFR_02 | The platform shall support at least 5,000 concurrent active users without critical service failure. | Horizontal scaling and load balancing are required for traffic peaks. | 1 | 03/04/2026 | Ilion Elezaj / Gëzime Mirku |
| NFR_03 | The platform shall maintain 99.5% monthly availability excluding planned maintenance windows. | Downtime events must be monitored and reported with root-cause notes. | 1 | 03/04/2026 | Klaus Saliaj / Ronad Lamani |
| NFR_04 | All sensitive data in transit shall use TLS 1.2+ and account passwords shall be securely hashed with salt at rest. | Security controls protect credentials, sessions, and personal user information. | 1 | 03/04/2026 | Revi Beja / Briana Llapaj |
| NFR_05 | Role-based authorization shall enforce least-privilege access across Goer, Business, and Admin operations. | Users must not access actions or data outside their role permissions. | 1 | 03/04/2026 | Angjelina Zenunaj / Klaus Saliaj |
| NFR_06 | Personal and lead data processing shall require consent and follow applicable privacy regulations. | Consent records must be stored and auditable for compliance checks. | 1 | 03/04/2026 | Ilion Elezaj / Revi Beja |
| NFR_07 | The system shall perform daily backups with RPO of 24 hours and RTO of 4 hours. | Backup restoration procedures must be tested on a regular schedule. | 2 | 03/04/2026 | Briana Llapaj / Ronad Lamani |
| NFR_08 | The user interface shall be responsive on mobile and desktop and aligned with WCAG 2.1 AA accessibility practices. | This includes readable contrast, keyboard navigation, and clear labels. | 2 | 03/04/2026 | Gëzime Mirku / Angjelina Zenunaj |
| NFR_09 | The codebase shall maintain quality gates with automated tests and static checks before deployment. | Build pipelines must block production release when critical checks fail. | 2 | 03/04/2026 | Klaus Saliaj / Revi Beja |
| NFR_10 | Audit logs for moderation, disputes, verification, and critical admin actions shall be retained for at least 12 months. | Logs must support traceability, incident response, and accountability reviews. | 2 | 03/04/2026 | Ronad Lamani / Briana Llapaj |
