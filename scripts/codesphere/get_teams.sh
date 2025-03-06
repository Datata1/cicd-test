#!/bin/bash

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

echo "RESPONSE=$RESPONSE" >> envvars