# Continuous Integration/Delivery

This guide is for CI-CD using GitHub Actions.

If GitHub Actions are not available in your environment, or as a complement for fast local feedback, refer to the alternative guide [to run integration and delivery locally](manual-delivery.md).

## Deploy Azure resources

Deploy the following Azure Resources

- Azure OpenAI
- Azure AI Search
- Azure ML Workspace
- Two Azure [User-Assigned Managed Identities](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-manage-user-assigned-managed-identities):
  - One for CD (the identity of the GitHub Actions runner deploying model and endpoint)
  - One for the online endpoint (the identity of the REST endpoint, downloading model assets and connection secrets from Azure ML)

## Configure application federated credentials

Follow the instructions to [
use the Azure login action with OpenID Connect](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Clinux#use-the-azure-login-action-with-openid-connect).

Create two Federated credentials for your Organization and Repository:

- One with Entity `Branch` and Branch `main`.
- One with Entity `Pull request`.

## Configure repository action settings

### Secrets

| Secret name    | Value                                                     | Example |
| -------------- | --------------------------------------------------------- | ------- |
| `AISEARCH_KEY` | The access key for your deployed Azure AI Search instance |         |
| `OPENAI_KEY`   | The access key for your deployed Azure OpenAI instance    |         |

### Variables

| Variable name              | Value                                                        | Example                                                      |
| -------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| `AISEARCH_ENDPOINT`        | The endpoint for your deployed Azure AI Search instance      | `https://mve.search.windows.net`                             |
| `AZURE_ML_WORKSPACE`       | The name of the Azure ML workspace                           | `mveazureml`                                                 |
| `AZURE_CLIENT_ID`          | The client ID of the managed identity created for CD         | `9b7af88e-e726-48ce-a44d-9dc8c947fc4b`                       |
| `AZURE_RESOURCE_GROUP`     | The resource group of the Azure ML workspace                 | `promptflow-demo`                                            |
| `AZURE_SUBSCRIPTION_ID`    | The subscription ID of Azure resources                       | `c3055f19-326c-4ff3-a9f7-4531fd14f73e`                       |
| `AZURE_TENANT_ID`          | The tenant ID of Azure resources                             | `2ac1091e-2d47-4212-9453-0ca0db6c21d7`                       |
| `ENDPOINT_IDENTITY_ARM_ID` | The Azure Resource Manager Resource ID of the managed identity created for the online endpoint | `/subscriptions/c3055f19-326c-4ff3-a9f7-4531fd14f73e/resourceGroups/algattik-ai-exploration/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mve-uami-endpoint` |
| `OPENAI_ENDPOINT`          | The endpoint for your deployed Azure OpenAI instance         | `https://mve.openai.azure.com`                               |

**Hint**: You can create variables in batch from an `.env` file by running the following [GitHub CLI
command](https://cli.github.com/manual/gh_variable_set) in context of the repository:

```bash
gh variable set -f .env
```

## Create connections in Azure ML

In Azure ML Studio, under `Prompt flow`, in the `Connections` tab, create the following connections:

| Connection name        | Connection type    | Description                                             |
| ---------------------- | ------------------ | ------------------------------------------------------- |
| `open_ai_connection`   | `Azure OpenAI`     | Configure the endpoint of your Azure OpenAI instance    |
| `ai_search_connection` | `Cognitive search` | Configure the endpoint of your Azure AI Search instance |

The connections are used by the Azure ML endpoint deployed by the pipeline.

## Grant Azure role assignments

### Model deployment

Grant the following IAM role assignments to allow the pipeline to deploy models:

- Resource: your Azure ML workspace
- Role: [`AzureML Data Scientist`](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azureml-data-scientist)
- Identity: the managed identity you created for CD

### Managed identity assignment

Grant the following IAM role assignments to allow  the pipeline to assign the managed identity to the deployed online endpoint:

- Resource: the managed identity you created for the online endpoint
- Role: [`Managed Identity Operator`](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#managed-identity-operator)
- Identity: the managed identity you created for CD

### Deployment workspace resources

Grant the following IAM role assignments to [allow the endpoint deployment to deploy the container image and artifacts from the workspace](https://learn.microsoft.com/en-us/azure/machine-learning/how-to-troubleshoot-online-endpoints?view=azureml-api-2&tabs=cli#authorization-error).

First role assignment:

- Resource: the storage account for the Azure ML workspace
- Role: [`Storage blob data reader`](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage-blob-data-reader)
- Identity: the managed identity you created for the endpoint

Second role assignment:

- Resource: the Azure Container Registry (ACR) for the Azure ML workspace
- Role: [`AcrPull`](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#acrpull)
- Identity: the managed identity you created for the endpoint

### Endpoint workspace secrets

Grant the following IAM role assignments to [allow the endpoint to retrieve secrets](https://aka.ms/pf-deploy-identity):

- Resource: your Azure ML workspace
- Role: `Azure Machine Learning Workspace Connection Secrets Reader`
- Identity: the managed identity you created for the endpoint
