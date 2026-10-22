# CustomDomains

[`example-com.yaml`](example-com.yaml) is an example CustomDomain for `example.com`, owned by the platform's admin.

Its verification is expected to fail: nobody can delegate `example.com`'s NS records to a Smarter platform. It
shows the manifest's shape. To use your own domain, copy it, change `domainName` to a domain you control, apply it,
and delegate the domain's NS records as the platform tells you.

Documentation: https://docs.smarter.sh/en/latest/smarter-resources/smarter-custom-domain.html
