#!/bin/bash

WORKSPACE_ID=$1

DELETE_RESPONSE=$(curl -s -X DELETE \
    -H "Authorization: Bearer $TOKEN_ENV" \
    -H "accept: application/json" \
    "https://codesphere.com/api/workspaces/$WORKSPACE_ID/landscape/teardown")

echo $DELETE_RESPONSE