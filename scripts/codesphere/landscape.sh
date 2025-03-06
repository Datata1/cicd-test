#!/bin/bash

if [[ -z "$1" ]]; then
    echo "❌ Parameter fehlt!"
    echo "Usage: ./landscape.sh <WORKSPACE_ID>"
    exit 1
fi

WORKSPACE_ID=$1

echo "🚧 Teardown der Landscape für Workspace $WORKSPACE_ID..."

TEARDOWN_RESPONSE=$(curl -s -X DELETE \
    -H "Authorization: Bearer $TOKEN_ENV" \
    -H "accept: application/json" \
    "https://codesphere.com/api/workspaces/$WORKSPACE_ID/landscape/teardown")

echo "Original RESPONSE (Teardown): $TEARDOWN_RESPONSE"

if echo "$TEARDOWN_RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
    echo "❌ Fehler beim Teardown: $(echo "$TEARDOWN_RESPONSE" | jq -r '.error.message')"
    exit 1
fi

echo "✅ Teardown erfolgreich abgeschlossen!"

echo "🚀 Starte Landscape Deployment..."

DEPLOY_RESPONSE=$(curl -s -X POST \
    -H "Authorization: Bearer $TOKEN_ENV" \
    -H "accept: application/json" \
    "https://codesphere.com/api/workspaces/$WORKSPACE_ID/landscape/deploy")


if echo "$DEPLOY_RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
    echo "❌ Fehler beim Landscape Deploy: $(echo "$DEPLOY_RESPONSE" | jq -r '.error.message')"
    exit 1
fi

echo "✅ Landscape erfolgreich deployed!"

echo "LANDSCAPE_TEARDOWN=true" >> envvars
echo "LANDSCAPE_DEPLOY=true" >> envvars