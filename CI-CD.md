# Continuous Integration/Delivery

## Create an application for CD

[Create a Microsoft Entra application and service principal](
https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Clinux#use-the-azure-login-action-with-openid-connect).

You can also create the application as an Azure [User-Assigned Managed Identity](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-azp.)

## Configure application federated credentials

Follow the instructions to [
use the Azure login action with OpenID Connect](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Clinux#use-the-azure-login-action-with-openid-connect).

Create two Federated credentials for your Organization and Repository: 

- One with Entity `Branch` and Branch `main`.
- One with Entity `Pull request`.

## Deploy Azure resources

Deploy the following Azure Resources

- Azure OpenAI
- Azure AI Search
- Azure ML Workspace

## Configure repository action settings

### Secrets

| Secret name    | Value                                                     | Example |
| -------------- | --------------------------------------------------------- | ------- |
| `AISEARCH_KEY` | The access key for your deployed Azure AI Search instance |         |
| `OPENAI_KEY`   | The access key for your deployed Azure OpenAI instance    |         |
|                |                                                           |         |

### Variables

| Variable name           | Value                                                   | Example                                |
| ----------------------- | ------------------------------------------------------- | -------------------------------------- |
| `AISEARCH_ENDPOINT`     | The endpoint for your deployed Azure AI Search instance | `https://mve.search.windows.net`       |
| `AZURE_CLIENT_ID`       | The client ID of the application                        | `27b4fd5c-ab61-4f78-8338-5706f03d9073` |
| `AZURE_SUBSCRIPTION_ID` | The subscription ID of Azure resources                  | `c3055f19-326c-4ff3-a9f7-4531fd14f73e` |
| `AZURE_TENANT_ID`       | The tenant ID of Azure resources                        | `2ac1091e-2d47-4212-9453-0ca0db6c21d7` |
| `OPENAI_ENDPOINT`       | The endpoint for your deployed Azure OpenAI instance    | `https://mve.openai.azure.com`         |

## Grant Azure resource access

Grant the following RBAC role to allow the pipeline to deploy models:

- Identity: the application you created for CD
- Resource: your Azure ML workspace
- Role: [`AzureML Data Scientist`](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azureml-data-scientist)

