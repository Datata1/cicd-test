#!/bin/bash

if [[ -z "$1" ]]; then
    echo "❌ Kein Workspace-ID übergeben!"
    echo "Usage: ./pull_repo.sh <WORKSPACE_ID>"
    exit 1
fi

WORKSPACE_ID=$1
REMOTE="origin"
BRANCH=${CI_COMMIT_SOURCE_BRANCH} # GitLab Umgebungsvariable

if [[ -z "$BRANCH" ]]; then
    echo "❌ CI_COMMIT_SOURCE_BRANCH ist leer!"
    exit 1
fi

echo "🚀 Pull-Request für Workspace $WORKSPACE_ID auf Branch $BRANCH wird gestartet..."

RESPONSE=$(curl -s -X POST \
    -H "Authorization: Bearer $TOKEN_ENV" \
    -H "accept: application/json" \
    https://codesphere.com/api/workspaces/$WORKSPACE_ID/git/pull/$REMOTE/$BRANCH)


if echo "$RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
    echo "❌ Fehler beim Pull-Request: $(echo "$RESPONSE" | jq -r '.error.message')"
    exit 1
fi

echo "✅ Git Pull erfolgreich gestartet!"

echo "GIT_PULL_RESPONSE=$RESPONSE" >> envvars