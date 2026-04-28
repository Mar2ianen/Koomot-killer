# Security Policy

This project is not security-critical yet, but it will eventually process user-supplied GPX files and map data. Treat parsers and importers as untrusted-input boundaries.

## Reporting

Please open a private security advisory on GitHub if available. If not, open an issue with minimal public details and mark it as security-related.

## Scope

Relevant issues include:

- crashes or panics caused by malformed GPX files;
- path traversal in import/export code;
- unsafe native bindings;
- dependency vulnerabilities;
- incorrect handling of local files;
- map tile or data source abuse risks.

## Non-goals for now

- vulnerabilities in third-party tile providers;
- incorrect OSM data;
- route quality or navigation mistakes.

## Dependency policy

Prefer permissive, actively maintained dependencies. Avoid adding GPL/LGPL runtime dependencies without a clear license review.
