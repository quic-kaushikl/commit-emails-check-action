# commit-emails-check-action

[![CI](https://github.com/qualcomm/commit-emails-check-action/actions/workflows/ci.yaml/badge.svg)](https://github.com/qualcomm/commit-emails-check-action/actions/workflows/ci.yaml)

Qualcomm PR email addresses checker

For each commit in a PR, validates that the commit's author and committer email
addresses are appropriate for the repo.

**NOTE:** This action should be used with `pull_request` events.

## Example Usage

```yaml
uses: qualcomm/commit-emails-check-action@main
```
