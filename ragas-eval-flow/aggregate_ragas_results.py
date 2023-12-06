from typing import List
from promptflow import tool, log_metric
import numpy as np


@tool
def aggregate_ragas_results(results: List[dict]):
    aggregate_results = {}

    for result in results:
        for name, value in result.items():
            if name not in aggregate_results:
                aggregate_results[name] = []
            try:
                float_val = float(value)
            except Exception:
                float_val = np.nan
            aggregate_results[name].append(float_val)

    for name, value in aggregate_results.items():
        aggregate_results[name] = np.nanmean(value)
        aggregate_results[name] = round(aggregate_results[name], 2)
        log_metric(name, aggregate_results[name])

    return aggregate_results
