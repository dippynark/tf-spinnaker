#!/bin/bash

SPINNAKER_API="https://gate.spinnaker.lukeaddison.co.uk"
# https://github.com/spinnaker/roer/issues/4
GITHUB_PERSONAL_ACCESS_TOKEN="bc22a51a47707bf388c64e10992f1d49295e4c77"

# setup github webhook
# https://developer.github.com/v3/repos/hooks
RESPONSE=$(curl -sX GET \
  -H "Authorization: token ${GITHUB_PERSONAL_ACCESS_TOKEN}" \
  https://api.github.com/repos/dippynark/goldengoose/hooks \
  | jq '.[] | select(.config.url == "https://gate.spinnaker.lukeaddison.co.uk/webhooks/git/github")')

HOOK_ID=$(echo ${RESPONSE} | jq '.id')

if [ -z "$HOOK_ID" ]; then
  curl -X POST \
    -H "Authorization: token ${GITHUB_PERSONAL_ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{
  "name": "web",
  "active": true,
  "events": [
    "push"
  ],
  "config": {
    "url": "https://gate.spinnaker.lukeaddison.co.uk/webhooks/git/github",
    "content_type": "json",
    "secret": "Gaf1ohwiloh0iegheiqu"
  }
}' https://api.github.com/repos/dippynark/goldengoose/hooks
else
  CONTAINS_PUSH=$(echo ${RESPONSE} | jq '.events | contains(["push"])')

  if [ "x${CONTAINS_PUSH}" == "xfalse" ]
  then
    curl -X PATCH \
      -H "Authorization: token ${GITHUB_PERSONAL_ACCESS_TOKEN}" \
      -H "Content-Type: application/json" \
      -d '{
  "name": "web",
  "active": true,
  "events": [
    "push"
  ],
  "config": {
    "url": "https://gate.spinnaker.lukeaddison.co.uk/webhooks/git/github",
    "content_type": "json",
    "secret": "Gaf1ohwiloh0iegheiqu"
  }
}' https://api.github.com/repos/dippynark/goldengoose/hooks/${HOOK_ID}
  fi

fi

# authenticate to spinnaker
if [ ! -f ~/.spin/config ]; then
  mkdir -p ~/.spin
  cat <<EOF > ~/.spin/config
auth:
  enabled: true
  oauth2:
    authUrl: https://github.com/login/oauth/authorize # OAuth2 provider auth url
    tokenUrl: https://github.com/login/oauth/access_token # OAuth2 provider token url
    clientId: ef9041a686b0e57a31fc # OAuth2 client id
    clientSecret: afcff44212b2822b03fcc016e3b414145dddd379 # OAuth2 client secret
    scopes:
    - scope1
EOF
fi

if ! spin --gate-endpoint https://gate.spinnaker.lukeaddison.co.uk application get goldengoose; then
  spin --gate-endpoint ${SPINNAKER_API} application save --application-name goldengoose --owner-email luke.addison@jetstack.io --cloud-providers kubernetes --file application-goldengoose.json
fi

if ! spin --gate-endpoint ${SPINNAKER_API} pipeline get --application goldengoose --name Build; then
  spin --gate-endpoint ${SPINNAKER_API} pipeline save --file <(cat templates/pipeline-build.json.tpl | sed "s/UUID/$(uuidgen)/g")
fi

if ! spin --gate-endpoint ${SPINNAKER_API} pipeline get --application goldengoose --name Deploy; then
  spin --gate-endpoint ${SPINNAKER_API} pipeline save --file <(cat templates/pipeline-deploy.json.tpl | sed "s/UUID/$(uuidgen)/g")
fi
