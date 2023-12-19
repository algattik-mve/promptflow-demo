# Manual Delivery

As an alternative to [continuous delivery using GitHub Actions](CI-CD.md), the workflows may also be run locally using [act](https://github.com/nektos/act).

## Deploy Azure resources

Deploy the following Azure Resources

- Azure OpenAI
- Azure AI Search
- Azure ML Workspace
- One Azure [User-Assigned Managed Identities](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-manage-user-assigned-managed-identities):
  - One for the online endpoint (the identity of the REST endpoint, downloading model assets and connection secrets from Azure ML)

## Configure action settings

### Secrets

Copy the file `.secrets.example` to `.secrets` and fill:

| Secret name    | Value                                                     | Example |
| -------------- | --------------------------------------------------------- | ------- |
| `AISEARCH_KEY` | The access key for your deployed Azure AI Search instance |         |
| `OPENAI_KEY`   | The access key for your deployed Azure OpenAI instance    |         |

### Variables

Copy the file `.variables.example` to `.variables` and fill:

| Variable name              | Value                                                        | Example                                                      |
| -------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| `AISEARCH_ENDPOINT`        | The endpoint for your deployed Azure AI Search instance      | `https://mve.search.windows.net`                             |
| `AZURE_ML_WORKSPACE`       | The name of the Azure ML workspace                           | `mveazureml`                                                 |
| `AZURE_RESOURCE_GROUP`     | The resource group of the Azure ML workspace                 | `promptflow-demo`                                            |
| `AZURE_SUBSCRIPTION_ID`    | The subscription ID of Azure resources                       | `c3055f19-326c-4ff3-a9f7-4531fd14f73e`                       |
| `ENDPOINT_IDENTITY_ARM_ID` | The Azure Resource Manager Resource ID of the managed identity created for the online endpoint | `/subscriptions/c3055f19-326c-4ff3-a9f7-4531fd14f73e/resourceGroups/algattik-ai-exploration/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mve-uami-endpoint` |
| `OPENAI_ENDPOINT`          | The endpoint for your deployed Azure OpenAI instance         | `https://mve.openai.azure.com`                               |

## Create connections in Azure ML

In Azure ML Studio, under `Prompt flow`, in the `Connections` tab, create the following connections:

| Connection name        | Connection type    | Description                                             |
| ---------------------- | ------------------ | ------------------------------------------------------- |
| `open_ai_connection`   | `Azure OpenAI`     | Configure the endpoint of your Azure OpenAI instance    |
| `ai_search_connection` | `Cognitive search` | Configure the endpoint of your Azure AI Search instance |

The connections are used by the Azure ML endpoint deployed by the workflow.

## Grant Azure role assignments

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

## Run integration

[Install Docker and act](https://github.com/nektos/act#installation).

```bash
./local-workflow.sh [act-parameters]
```

The default command without parameters will run all workflows. The script accepts parameters that are passed to the `act` command (see `act --help` for reference), for example:

- `--workflows .github/workflows/run-eval-pf-pipeline.yml`: run only the specified workflow
- ``--verbose`: verbose output

On the first run, you will be presented with a prompt such as this one: 

```
| Please run 'az login' to setup account.
| To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code E84CTTNT5 to authenticate.
```

Follow the link, input the code and log in. The authentication token will be stored to the `.azure.secrets` directory. Make sure to keep this local directory safe!
