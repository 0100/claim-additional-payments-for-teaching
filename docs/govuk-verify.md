# GOV.UK Verify Integration

For an overview of how the service uses GOV.UK Verify for identity assurance see
the
[service’s Confluence space](https://dfedigital.atlassian.net/wiki/spaces/TP/pages/1106444353/GOV.UK+Verify).
There is more general information about GOV.UK Verify on the
[GOV.UK Verify documentation site](https://www.docs.verify.service.gov.uk).

## Getting support

Visit [GOV.UK Verify Support](https://www.verify.service.gov.uk/support/) for
the most up-to-date way to get support. There is also a #govuk-verify slack
channel on the ukgovernmentdigital.slack.com slack workspace.

## Environment variables

GOV.UK Verify integration requires certain environment variables be set:

```bash
GOVUK_VERIFY_VSP_HOST=http://URL.FOR.VSP:12345
```

## Running locally in development

GOV.UK Verify integration requires using a Verify Service Provider (VSP) to
handle SAML secure messaging.

By default, Foreman downloads and runs the VSP via `foreman start` in
development with sample data for LOA 2. You must have Java 11, or a long-term
supported version of Java 8 installed for this to run successfully. We recommend
[openjdk](https://adoptopenjdk.net/)

You can check that the VSP is running ok by hitting the healthcheck URL:

```bash
curl localhost:50300/admin/healthcheck
```

### How to complete the GOV.UK Verify user journey in local development

After beginning the GOV.UK Verify flow, you will be redirected to a URL which
looks something like
`https://compliance-tool-reference.ida.digital.cabinet-office.gov.uk/SAML2/SSO`,
and which will display a JSON object in your browser. To complete the GOV.UK
Verify flow from here:

1. Follow the `responseGeneratorLocation` URL from this JSON object.
2. This will give you another JSON object, which provides `executeUri` URLs
   which you can follow to simulate various Verify outcomes. For example, to
   simulate a successful Verify outcome, use the test case whose title at the
   time of writing is "Verified User On Service With Non Match Setting".

These steps are explained in more detail in the
[GOV.UK Verify documentation](https://www.docs.verify.service.gov.uk/get-started/set-up-successful-verification-journey/#run-the-identity-verified-response-scenario).

### How to simulate skipping the GOV.UK Verify user journey in local development

Users that are unable to complete the GOV.UK Verify process are still able to
submit a claim. To do so they are linked back to the service on the GOV.UK
Verify failure screen so they can provide their identity information and
complete their claim. Such claims are then manually check to confirm the
claimants identity. To simulate such a claim, visit the following URL after you
reach the screen just before the GOV.UK Verify stage:

https://localhost:3000/verify/authentications/skip

## Rotating keys and certificates

The VSP uses keys and certificates to encrypt requests and decrypt responses
from GOV.UK Verify. These need to be rotated regularly. See
[GOV.UK Verify – Rotating keys and certificates](docs/govuk-verify-rotating-keys-and-certificates.md)
for instructions on doing this.
