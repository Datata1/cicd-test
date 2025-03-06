ENVIRONMENT_NAME="codesphere"

echo "🚀 Erstelle bzw. aktualisiere das Environment '$ENVIRONMENT_NAME' im Repository ${OWNER}/${REPO} ..."

RESPONSE=$(curl -s -X PUT \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${CI_REPO_OWNER}/${CI_REPO_NAME}/environments/${ENVIRONMENT_NAME}")

echo "Antwort der API:"
echo "$RESPONSE"