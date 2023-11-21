# Chat with Patents data

This is a simple flow that allow you to ask questions about the content of patents (or any other data) indexed in Azure AI search and get answers.
You can run the flow with a question as argument.
It will look up the index to retrieve relevant content and post the question with the relevant content to OpenAI chat model (`gpt-35-turbo`) to get an answer.

## Prerequisites

#### Local environment

Install promptflow sdk and other dependencies:

```bash
pip install -r requirements.txt
```

#### Azure OpenAI Service

Deploy an Azure Open AI workspace.

In Azure Open AI Studio, create the following deployments:

| Model                    | Deployment name          |
| ------------------------ | ------------------------ |
| `text-embedding-ada-002` | `text-embedding-ada-002` |
| `gpt-35-turbo`           | `gpt-35-turbo`           |

#### Azure AI Search data

Use the https://github.com/algattik/fetch-patents utility to download patents for the company of interest.

Create a storage account with a container named `docx`.

Copy the downloaded patents to the storage account:

```
az storage blob sync -c docx --account-name $STORAGE_ACCOUNT -s docx
```

In Azure Open AI Studio, follow the [instructions to Add your data using Azure OpenAI Studio](https://learn.microsoft.com/en-us/azure/ai-services/openai/use-your-data-quickstart).

- Data source: `Azure Blob Storage`
- Select Azure Blob storage resource: your storage account containing patents data
- Select storage container: `docx`
- Select Azure AI Search resource: select or create a new resource
- Enter the index name: `patents`
- Add vector search to this search resource: checked
- Select an embedding model: `Azure OpenAI - text-embedding-ada-002`

In the second screen, select:

- Search type: `Hybrid (vector + keyword)`

After closing the wizard, wait for the indexing to be completed.

## Get started

### Create Azure OpenAI connection

```bash
# create connection needed by flow
if pf connection list | grep open_ai_connection; then
    echo "open_ai_connection already exists"
else
    pf connection create --file ../connections/azure_openai.yml --name open_ai_connection --set api_key=<your_api_key> api_base=https://<your openai name>.openai.azure.com
fi
```

### Create Azure AI Search connection

```bash
# create connection needed by flow
if pf connection list | grep ai_search_connection; then
    echo "ai_search_connection already exists"
else
    pf connection create --file ../connections/azure_ai_search.yml --name ai_search_connection --set api_key=<your_api_key> api_base=https://<your ai search name>.search.windows.net
fi
```

### CLI Example

#### Run flow

```bash
# test with default input value in flow.dag.yaml
pf flow test --flow .

# test with flow inputs
pf flow test --flow . --inputs question="How does the car know how much fuel is in the tank?"
```

