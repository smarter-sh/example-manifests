# LLMHostComputes

Built-in LLMHostCompute manifests: the kinds of node that LLMHosts run on, from a small CPU node to eight NVIDIA
H100s. Each one is a Kubernetes node group, which Smarter creates when an LLMHost first needs one of its nodes, and
whose nodes it adds and removes as LLMHosts are launched and destroyed.

Every platform applies them for its admin, so that every account may use them. An LLMHost names its compute in
`spec.compute`, and its `spec.resources` must fit that node: see [`../llmhosts/`](../llmhosts/).

Documentation: https://docs.smarter.sh/en/latest/smarter-resources/smarter-llmhost.html
