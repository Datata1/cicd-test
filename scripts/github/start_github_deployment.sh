#!/bin/bash

echo "🚀 Starte Deployment für PR #${CI_COMMIT_PULL_REQUEST} ..."

DEPLOYMENT_RESPONSE=$(curl -X POST \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "{\"ref\": \"${CI_COMMIT_SOURCE_BRANCH}\", \"task\": \"deploy\", \"environment\": \"codesphere\", \"description\": \"Deployment für PR #${CI_COMMIT_PULL_REQUEST}\", \"required_contexts\": []}" \
    "https://api.github.com/repos/${CI_REPO_OWNER}/${CI_REPO_NAME}/deployments")

echo $DEPLOYMENT_RESPONSE
DEPLOYMENT_ID=$(echo "$DEPLOYMENT_RESPONSE" | jq -r .id)

if [[ "$DEPLOYMENT_ID" == "null" ]]; then
    echo "❌ Fehler beim Erstellen des Deployments."
    exit 1
fi

echo "✅ Deployment gestartet! Deployment ID: $DEPLOYMENT_ID"
echo "DEPLOYMENT_ID=$DEPLOYMENT_ID" >> envvars