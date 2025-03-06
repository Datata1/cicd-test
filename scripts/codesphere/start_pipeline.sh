#!/bin/bash

if [[ -z "$1" || -z "$2" ]]; then
    echo "❌ Parameter fehlen!"
    echo "Usage: ./start_pipeline.sh <WORKSPACE_ID> <STAGE>"
    exit 1
fi

WORKSPACE_ID=$1
STAGE=$2
MAX_RETRIES=3000 
COUNTER=0

echo "🚀 Starte Pipeline '$STAGE' für Workspace $WORKSPACE_ID..."

START_RESPONSE=$(curl -s -X POST \
    -H "Authorization: Bearer $TOKEN_ENV" \
    -H "accept: application/json" \
    "https://codesphere.com/api/workspaces/$WORKSPACE_ID/pipeline/$STAGE/start")


if echo "$START_RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
    echo "❌ Fehler beim Starten der Pipeline: $(echo "$START_RESPONSE" | jq -r '.error.message')"
    exit 1
fi

echo "✅ Pipeline wurde gestartet!"

if [[ "$STAGE" == "run" ]]; then
    echo "🔄 Kein Polling notwendig für Stage: $STAGE"
    echo "PIPELINE_STAGE=$STAGE" >> envvars
    echo "PIPELINE_STATUS=started" >> envvars
    exit 0
fi

echo "🔄 Warte auf Pipeline-Status für Stage: $STAGE..."

while [[ $COUNTER -lt $MAX_RETRIES ]]; do
    STATUS_RESPONSE=$(curl -s -X GET \
        -H "Authorization: Bearer $TOKEN_ENV" \
        -H "accept: application/json" \
        "https://codesphere.com/api/workspaces/$WORKSPACE_ID/pipeline/$STAGE")

    echo "====================="

    FILTERED_RESPONSE=$(echo "$STATUS_RESPONSE" | jq -c '.[] | select(.server == "codesphere-ide")')

    if [[ -z "$FILTERED_RESPONSE" ]]; then
        echo "⚠️ Keine passende Pipeline gefunden (server: codesphere-ide)"
        sleep 1
        COUNTER=$((COUNTER + 1))
        continue
    fi

    STATE=$(echo "$FILTERED_RESPONSE" | jq -r ".state")

    echo "Pipeline-Status: $STATE"

    if [[ "$STATE" == "success" ]]; then
        echo "✅ Pipeline erfolgreich abgeschlossen!"
        break
    elif [[ "$STATE" == "failed" ]]; then
        echo "❌ Pipeline fehlgeschlagen!"
        exit 1
    fi

    echo "🔍 Steps:"
    echo "$FILTERED_RESPONSE" | jq -c ".steps[]" | while read -r step; do
        STEP_STATE=$(echo "$step" | jq -r '.state')
        echo " ➡️ Step Status: $STEP_STATE"
    done

    COUNTER=$((COUNTER + 1))
    sleep 1
done

if [[ $COUNTER -eq $MAX_RETRIES ]]; then
    echo "❌ Timeout! Pipeline hat nach 5 Minuten nicht abgeschlossen."
    exit 1
fi

echo "PIPELINE_STAGE=$STAGE" >> envvars
echo "PIPELINE_STATUS=$STATE" >> envvars