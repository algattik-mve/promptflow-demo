# Evaluate Q&A flow

This is a simple flow that evaluates the Q&A flow outputs using various metrics.
It contains a set of metrics - LLM-based, embedding-based and text-based and the user can choose which ones should be calculated during the pipeline run.

## Included metrics

There are 7 metrics included in the flow. They are:

- LLM based metrics:
  - Groundedness (answer, context) - Does the answer follow information retrieved from the context
  - Relevance (question, answer, context) - How well the answer addresses the main aspects of the question, based on the context
  - Similarity (answer, ground truth) -  The semantic similarity between the predicted answer and the correct answer
  - Coherence (question, answer) - How well all the sentences fit together and sound naturally as a whole
  - Fluence (question, answer) - the quality of individual sentences in the answer, and whether they are well-written and grammatically correct
- Embedding based metrics:
  - ADA similarity (answer, ground truth) - Cosine similarity between embedding vectors (using the ada embedding model) between answer and ground truth
- Text based metrics:
  - F1 score (answer, ground truth) - F1 Score calculated using the common words in the answer and ground truth

All of the metrics return a number - LLM based between 1 and 5, and the others between 0.0 and 1.0.

_Warning:_ The prompts for the LLM based are not tuned and to be improved in the further steps of the project.

## Flow description

### Inputs

There are four inputs to the flow:

- question - The question that was asked to the Q&A model
- answer - Answer received from the Q&A model
- context - Context that was provided to the Q&A model in order to provide information that should be used to create an answer
- ground_truth - Expected correct answer prepared by SME for the question

### Outputs

The flow generates 7 outputs, one for each calculated metric:
f1_score, gpt_coherence, gpt_similarity, gpt_fluency, gpt_relevance, gpt_groundedness, ada_similarity

### Execution modes

The flow can be executed in two modes - single case and batch execution.

#### Single case testing

The flow can be executed with just one example using CLI and providing the inputs:

```bash
pf flow test --flow . --inputs question="How does the driver know how much fuel is in the tank?" answer="Turn on engine and look at the dashboard" ground_truth="Dashboard has a fuel gauge" context="The car is equipped with many gauges. When the engine is turned on you can check the battery level, fuel level, oil temperature."
```

#### Batch execution

The flow can be executed for a large number of test cases using CLI.

##### Source data run

In `../chat-with-patents`, run:

```
run_name="chat_with_patents_"$(openssl rand -hex 12)
```

```bash
pf run create --file batch_run.yaml --name "$run_name"
```

##### Evaluation run

1. Using yaml config of the run:

```
eval_run_name="eval_"$(openssl rand -hex 12)
```

```bash
pf run create --file evaluation_run.yaml --run "$run_name" --name "$eval_run_name"
```

Take note of the run name.

To visualize the outputs in a browser:

```bash
pf run visualize --name "$eval_run_name"
```

2. Using CLI without yaml configuration file:

```bash
pf run create --flow . --data ../data/data.jsonl --run "$run_name" --column-mapping ground_truth='${data.groundtruth}' question='${run.inputs.question}' answer='${run.outputs.output}' context='${run.outputs.context}' metrics='all' --stream
```
