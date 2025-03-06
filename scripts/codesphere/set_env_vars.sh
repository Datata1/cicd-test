#!/bin/bash

if [[ -z "$1" ]]; then
    echo "❌ Parameter fehlt!"
    echo "Usage: ./set_env_vars.sh <WORKSPACE_ID>"
    exit 1
fi

WORKSPACE_ID=$1
ENV_FILE=".env.codesphere"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "❌ Datei $ENV_FILE nicht gefunden!"
    exit 1
fi

echo "📄 Lese Environment Variables aus $ENV_FILE..."

ENV_VARS_JSON="["

while IFS= read -r line || [[ -n "$line" ]]; do
    # Leere Zeilen oder Kommentare überspringen
    if [[ -z "$line" || "$line" == \#* ]]; then
        continue
    fi

    IFS='=' read -r name value <<< "$line"
    IFS=

    if [[ -n "$name" && -n "$value" ]]; then
        ENV_VARS_JSON+="{\"name\": \"$name\", \"value\": \"$value\"},"
    fi
done < "$ENV_FILE"

ENV_VARS_JSON="${ENV_VARS_JSON%,}"
ENV_VARS_JSON+="]"

echo "📦 Payload:"
echo "$ENV_VARS_JSON" | jq .

echo "🚀 Setze Environment Variables für Workspace $WORKSPACE_ID..."

RESPONSE=$(curl -s -X PUT \
    -H "Authorization: Bearer $TOKEN_ENV" \
    -H "accept: application/json" \
    -H "Content-Type: application/json" \
    -d "$ENV_VARS_JSON" \
    "https://codesphere.com/api/workspaces/$WORKSPACE_ID/env-vars")


if echo "$RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
    echo "❌ Fehler beim Setzen der Env Vars: $(echo "$RESPONSE" | jq -r '.error.message')"
    exit 1
fi

echo "✅ Environment Variables erfolgreich gesetzt!"

echo "ENV_VARS_SET=true" >> envvars