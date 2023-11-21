from typing import List
from promptflow import tool
from promptflow_vectordb.core.contracts import SearchResultEntity


@tool
def generate_prompt_context(search_result: List[dict]) -> str:
    def format_doc(doc: dict):
        return f"Content: {doc['Content']}\nSource: {doc['Source']}"

    CONTENT_KEY = "content"
    URL_KEY = "url"

    retrieved_docs = []
    for item in search_result:

        entity = SearchResultEntity.from_dict(item)
        content = entity.text or ""
        
        source = ""
        if entity.original_entity is not None:
                if URL_KEY in entity.original_entity:
                    source = entity.original_entity[URL_KEY] or ""
                if CONTENT_KEY in entity.original_entity and not content:
                    content = entity.original_entity[CONTENT_KEY] or ""

        retrieved_docs.append({
            "Content": content,
            "Source": source
        })
    doc_string = "\n\n".join([format_doc(doc) for doc in retrieved_docs])
    return doc_string

