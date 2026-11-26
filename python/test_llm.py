# test_llm.py

from ollama import chat

response = chat(
    model="qwen2.5",
    messages=[
        {
            "role": "user",
            "content": "Explain PostgreSQL in two sentences."
        }
    ]
)

print(response.message.content)