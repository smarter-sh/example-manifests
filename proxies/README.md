# Proxies

Built-in Proxy manifests, which every platform applies for its admin, so that every account may use them. Each one
names one of the platform's built-in Providers, and the Secret that holds its API key, which the platform creates
from its environment, e.g. `openai` and `openai_api_key` from `OPENAI_API_KEY`. On a platform without a provider's
API key, its Proxy fails to apply, and the platform reports it.

Each one allows only its provider's inference endpoints, e.g. chat completions, embeddings and models, so that the
platform's provider accounts' files, fine-tuning jobs, batches and settings can't be reached through it.

| Proxy             | Provider     | API key Secret       | SDK           |
| ----------------- | ------------ | -------------------- | ------------- |
| `openai`          | `openai`     | `openai_api_key`     | OpenAI        |
| `anthropic`       | `anthropic`  | `anthropic_api_key`  | Anthropic     |
| `googleai`        | `googleai`   | `gemini_api_key`     | Google Gen AI |
| `googleai_openai` | `googleai`   | `gemini_api_key`     | OpenAI        |
| `mistral`         | `mistral`    | `mistral_api_key`    | Mistral       |
| `cohere`          | `cohere`     | `cohere_api_key`     | Cohere        |
| `fireworks`       | `fireworks`  | `fireworks_api_key`  | OpenAI        |
| `togetherai`      | `togetherai` | `togetherai_api_key` | Together      |
| `metaai`          | `metaai`     | `llama_api_key`      | Llama API     |

Documentation: https://docs.smarter.sh/en/latest/smarter-resources/smarter-proxy.html
