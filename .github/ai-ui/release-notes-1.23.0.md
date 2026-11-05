# Version 1.23.0
- Implemented the Credential Exchange Protocol (CXP) for importing credentials from and exporting them to other password managers
- Introduced the ability to ignore specific password issues, such as compromised, weak, or reused passwords (behind a feature flag)
- Enabled PRF for passkeys
- Updated manual autofill to account for exact subdomain matching
- Fixed incorrect alias counter values in some cases
- Fixed previews for file attachments containing non-alphanumeric characters

Others:
- Removed the legacy sync mechanism
- Rust library upgraded from 2.2.0 to 2.3.1
