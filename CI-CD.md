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

### Variables

| Variable name           | Value                                                   | Example                                |
| ----------------------- | ------------------------------------------------------- | -------------------------------------- |
| `AISEARCH_ENDPOINT`     | The endpoint for your deployed Azure AI Search instance | `https://mve.search.windows.net`       |
| `AZURE_CLIENT_ID`       | The client ID of the application                        | `27b4fd5c-ab61-4f78-8338-5706f03d9073` |
| `AZURE_SUBSCRIPTION_ID` | The subscription ID of Azure resources                  | `c3055f19-326c-4ff3-a9f7-4531fd14f73e` |
| `AZURE_TENANT_ID`       | The tenant ID of Azure resources                        | `2ac1091e-2d47-4212-9453-0ca0db6c21d7` |
| `OPENAI_ENDPOINT`       | The endpoint for your deployed Azure OpenAI instance    | `https://mve.openai.azure.com`         |

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

## Grant Azure resource access

Grant the following RBAC role to allow the pipeline to deploy models:

- Identity: the application you created for CD
- Resource: your Azure ML workspace
- Role: [`AzureML Data Scientist`](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azureml-data-scientist)

## Grant Endpoint permissions resource access

After the CI/CD pipeline has run a first time, the endpoint will be created, but is missing the permissions to retrieve secrets to authenticate to Azure OpenAI and Azure AI Search.

The pipeline contains a step to invoke the model, which will then fail with an error similar to:

```text
Access denied to list workspace secret due to invalid authentication. Please assign RBAC role 'Azure Machine Learning Workspace Connection Secrets Reader' to the endpoint for current workspace, and wait for a few minutes to make sure the new role takes effect. More details can be found in https://aka.ms/pf-deploy-identity.
```

Grant the following RBAC role to [allow the endpoint to retrieve secrets](https://aka.ms/pf-deploy-identity):

- Identity:  `Managed identity` -> ` Machine Learning online endpoint` -> `chat-with-patents`
- Resource: your Azure ML workspace
- Role: `Azure Machine Learning Workspace Connection Secrets Reader`

After that, rerun the pipeline.
