#!/bin/bash

if [[ -z "$1" ]]; then
    echo "❌ Kein Workspace-Name übergeben!"
    echo "Usage: ./get_workspace.sh <WORKSPACE_NAME>"
    exit 1
fi

WORKSPACE_NAME=$1
MAX_RETRIES=3000

RESPONSE=$(curl -s -X GET \
    -H "Authorization: Bearer $TOKEN_ENV" \
    -H "accept: application/json" \
    "https://codesphere.com/api/workspaces/team/$TEAM_ID")


if echo "$RESPONSE" | jq empty >/dev/null 2>&1; then
    echo "✅ RESPONSE ist JSON"
else
    echo "❌ RESPONSE ist KEIN JSON!"
    exit 1
fi

FILTERED_RESPONSE=$(echo "$RESPONSE" | jq -c ".[] | select(.name == \"$WORKSPACE_NAME\")")

if [[ -z "$FILTERED_RESPONSE" ]]; then
    echo "❌ Kein Workspace mit Name: $WORKSPACE_NAME gefunden!"
    exit 1
fi

WORKSPACE_ID=$(echo "$FILTERED_RESPONSE" | jq -r ".id")
DATACENTER_ID=$(echo "$FILTERED_RESPONSE" | jq -r '.dataCenterId')


echo "🔄 Warte auf Running-Status für Workspace: $WORKSPACE_NAME"

COUNTER=0
while [[ $COUNTER -lt $MAX_RETRIES ]]; do
    STATUS_RESPONSE=$(curl -s -X GET \
        -H "Authorization: Bearer $TOKEN_ENV" \
        -H "accept: application/json" \
        "https://codesphere.com/api/workspaces/$WORKSPACE_ID/status")

    IS_RUNNING=$(echo "$STATUS_RESPONSE" | jq -r ".isRunning")

    echo "Status: $IS_RUNNING"

    if [[ "$IS_RUNNING" == "true" ]]; then
        echo "✅ Workspace $WORKSPACE_NAME läuft!"
        break
    fi

    COUNTER=$((COUNTER + 1))
    sleep 1
done

if [[ $COUNTER -eq $MAX_RETRIES ]]; then
    echo "❌ Timeout! Workspace ist nach 5 Minuten nicht gestartet."
    exit 1
fi

echo "WORKSPACE_DEPLOYMENT=$FILTERED_RESPONSE" >> envvars
echo "WORKSPACE_ID=$WORKSPACE_ID" >> envvars
echo "DATACENTER_ID=$DATACENTER_ID" >> envvars