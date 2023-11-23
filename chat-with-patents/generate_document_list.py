from typing import List
from promptflow import tool
from promptflow_vectordb.core.contracts import SearchResultEntity


@tool
def generate_document_list(search_result: List[dict]) -> str:
    URL_KEY = "title"

    retrieved_docs = []
    for item in search_result:
        entity = SearchResultEntity.from_dict(item)
        source = ""
        if entity.original_entity is not None:
            if URL_KEY in entity.original_entity:
                source = entity.original_entity[URL_KEY] or ""
        retrieved_docs.append(source)
    return retrieved_docs
