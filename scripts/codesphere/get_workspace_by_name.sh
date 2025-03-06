#!/bin/bash

WORKSPACE_NAME="${CI_REPO_NAME}-PR#${CI_COMMIT_PULL_REQUEST}"
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

WORKSPACE_ID=$(echo "$FILTERED_RESPONSE" | jq -r ".id") >> envvars
DATACENTER_ID=$(echo "$FILTERED_RESPONSE" | jq -r '.dataCenterId') >> envvars