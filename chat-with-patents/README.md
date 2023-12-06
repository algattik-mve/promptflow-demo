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
    pf connection create --file ../connections/azure_openai.yaml --name open_ai_connection --set api_key=<your_api_key> api_base=https://<your openai name>.openai.azure.com
fi
```

### Create Azure AI Search connection

```bash
# create connection needed by flow
if pf connection list | grep ai_search_connection; then
    echo "ai_search_connection already exists"
else
    pf connection create --file ../connections/azure_ai_search.yaml --name ai_search_connection --set api_key=<your_api_key> api_base=https://<your ai search name>.search.windows.net
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

## Indexing documents

To create an index of the documents, we leverage the [RAG Experiment
Accelerator](https://github.com/microsoft/rag-experiment-accelerator).
This provides a simple way to create different sets of indexes in Azure AI Search, by specifying the parameters in the
configuration file. Refer to the
[documentation](https://github.com/microsoft/rag-experiment-accelerator?tab=readme-ov-file#how-to-use) to get started.

After running the indexing script, you should see indexes created in your Azure AI Search resource, with the following
naming pattern: `{NAME_PREFIX}-{chunk_size}-{overlap}-{dimension}-{ef_construction}-{ef_search}`, where:

- `name_prefix`: Name of experiment, search index name used for tracking and comparing jobs
- `chunk_size`: Size of each chunk e.g. [500, 1000, 2000]
- `overlap_size`: Overlap Size for each chunk e.g. [100, 200, 300]
- `dimension` : embedding size for each chunk e.g. [384, 1024]. Valid values are 384, 768,1024
- `ef_construction` : determines the value of Azure Cognitive Search vector configuration.
- `ef_search``:  determines the value of Azure Cognitive Search vector configuration.

Once the indexes are created, you can use an input parameter to specify which index to use for the search. If the input
parameter is not specified, the flow will use the default index `patents`.

```bash
# test with specified index
pf flow test --flow . --inputs search_index="patents-500-100-384-100-100"
```

Additionally, the parameter `search_index` can be specified for the CI/CD pipeline. The value can be provided when the
pipeline is triggered manually. For automatic triggers, the pipeline will use the value of the variable `AISEARCH_INDEX`,
or the value `patents` if the variable is not set.

