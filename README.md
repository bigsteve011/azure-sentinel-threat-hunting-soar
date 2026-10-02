# Modern Threat Hunting in Azure: Microsoft Sentinel KQL Analytics & Automated Logic App SOAR Playbooks

> Developing advanced Kusto Query Language (KQL) analytic rules in Microsoft Sentinel to detect identity spray, lateral movement across hybrid Azure VNets, and automated incident containment via Azure Logic Apps.

Companion repository for the article **[Modern Threat Hunting in Azure: Microsoft Sentinel KQL Analytics & Automated Logic App SOAR Playbooks](https://stephen-omowumi.pages.dev/articles/azure-sentinel-threat-hunting-soar)** by Stephen Omowumi.

## The problem

Alert fatigue in enterprise SOCs leads to missed adversary signals. Without automated orchestration, dwell time for sophisticated cloud credential compromises averages over 12 days before manual detection.

## Solution architecture

Ingest raw telemetry from Entra ID AuditLogs, SigninLogs, AzureActivity, and Defender for Cloud into Azure Log Analytics. Write stateful KQL rules mapping to MITRE ATT&CK tactics. Trigger serverless Azure Logic Apps to revoke user refresh tokens and isolate endpoints instantly.

## How it works

1. **Multi-Source Telemetry Normalization** — Collect Entra ID, Azure Firewall, and Kubernetes audit logs into Azure Sentinel data connectors.
2. **Stateful KQL Multi-Stage Detection** — Correlate anomalous login location (Impossible Travel) followed by rapid Key Vault access within 5 minutes.
3. **High-Fidelity Incident Generation** — Synthesize signals into a unified Sentinel Incident with automated MITRE ATT&CK tactic tagging.
4. **Automated SOAR Playbook Execution** — Azure Logic App automatically executes Entra ID Revoke-SignInSessions and notifies SOC Slack/Teams channel.

## Repository layout

```
queries/     KQL hunting queries (risky sign-in -> Key Vault secret access, impossible travel)
terraform/   Log Analytics workspace, Sentinel onboarding, scheduled analytics rules with entity mapping
playbooks/   ARM template for a Logic App playbook that revokes the user's sessions and comments on the incident
```

## Usage

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # set subscription_id
terraform init && terraform apply
```
Deploy the playbook into the same resource group:
```bash
az deployment group create -g rg-security-operations --template-file playbooks/revoke-user-sessions.json
```
Then grant the playbook's managed identity the Microsoft Graph `User.RevokeSessions.All` application permission and the **Microsoft Sentinel Responder** role, and attach it to the analytics rules with an automation rule.

The queries need the Entra ID `SigninLogs` and Key Vault diagnostic logs (`AzureDiagnostics`) flowing into the workspace.

## Outcomes (as described in the article)

| Measure | Result |
|---|---|
| MTTR Response Time | < 30 Secs |
| False Positive Reduction | 92% |
| MITRE ATT&CK Mapped | 100% |

## Key takeaways

- Reduces Mean Time to Respond (MTTR) from hours down to sub-30 seconds via automated SOAR playbooks
- Correlates identity, network, and cloud API telemetry to eliminate 92% of false positive alerts
- Automated containment prevents active data exfiltration without requiring human manual intervention

## Notes

This is a reference implementation. Names, account IDs, regions and allow-lists are placeholders: review and adapt them, and test in a non-production environment before rolling out.

## License

MIT — see [LICENSE](LICENSE).
