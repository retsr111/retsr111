# This workflow requires that you have an existing account with codescan.io
# For more information about configuring your workflow,
# read our documentation at https://github.com/codescan-io/codescan-scanner-action
name: CodeScan snapshot reko-bob@hotmail.com 

on:
  push:
    branches: [ main ]
  pull_request:
    # The branches below must be a subset of the branches above
    branches: [ main ]
  schedule:
    - cron: '19 14 * * 5'

jobs:
    CodeScan:
        runs-on: ubuntu-latest
        steps:
            -   name: Checkout repository
                uses: actions/checkout@v2
            -   name: Cache files
                uses: actions/cache@v2
                with:
                    path: |
                        ~/.sonar
                    key: ${{ runner.os }}-sonar
                    restore-keys: ${{ runner.os }}-sonar
            -   name: Run Analysis
                uses: codescan-io/codescan-scanner-action@master
                with:
                    login: ${{ secrets.CODESCAN_AUTH_TOKEN }}
                    organization: ${{ secrets.CODESCAN_ORGANIZATION_KEY }}
                    projectKey: ${{ secrets.CODESCAN_PROJECT_KEY }}
            -   name: Upload SARIF file
                uses: github/codeql-action/upload-sarif@v1
                with:
                    sarif_file: codescan.sarif
