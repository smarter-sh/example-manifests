# LLMHosts

Example LLMHost manifests for popular open-weight models on Hugging Face and in the Ollama library. Together they
demonstrate every inference engine (vLLM, SGLang, TGI, llama.cpp, Ollama and Text Embeddings Inference) and the
huggingface, ollama and url model sources, on GPU and CPU nodes. Each one names an LLMHostCompute from
[`../llmhost-computes/`](../llmhost-computes/) in `spec.compute`.

Every platform applies them for its admin, so that every account may use them. Applying one launches nothing: deploy
it to start its model.

```console
smarter apply -f llama-3.1-8b-instruct.yaml
smarter deploy llmhost llama_3_1_8b_instruct
smarter describe llmhost llama_3_1_8b_instruct
smarter describe llmhostcompute gpu_a10g_1x
```

Gated models (Llama, Gemma, Mistral) need a Hugging Face access token in a Smarter Secret named
`huggingface_token`, and their license accepted on huggingface.co.

Documentation: https://docs.smarter.sh/en/latest/smarter-resources/smarter-llmhost.html
