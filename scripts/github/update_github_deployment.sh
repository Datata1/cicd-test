#!/bin/bash

DEPLOYMENT_ID=$1
DATACENTER_ID=$2

echo "✅ Update Deployment-Status auf success für Deployment ID: $DEPLOYMENT_ID..."
echo "Workspace deployed in Datacenter: $DATACENTER_ID"

DEPLOYMENT_STATUS_RESPONSE=$(curl -X POST \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "{\"state\": \"success\", \"deployment_id\": \"$DEPLOYMENT_ID\", \"description\": \"Deployment erfolgreich abgeschlossen!\", \"environment_url\": \"https://$WORKSPACE_ID-3000.$DATACENTER_ID.codesphere.com/\"}" \
    "https://api.github.com/repos/${CI_REPO_OWNER}/${CI_REPO_NAME}/deployments/$DEPLOYMENT_ID/statuses")

echo "Verwende die URL: https://api.github.com/repos/${CI_REPO_OWNER}/${CI_REPO_NAME}/deployments/$DEPLOYMENT_ID/statuses"

if echo "$DEPLOYMENT_STATUS_RESPONSE" | jq -e '.state' | grep -q "success"; then
    echo "✅ Deployment Status erfolgreich auf 'success' gesetzt!"
else
    echo "❌ Fehler beim Setzen des Deployment-Status!"
    exit 1
fi