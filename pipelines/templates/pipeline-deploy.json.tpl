{
  "name": "Deploy",
  "application": "goldengoose",
  "id": "UUID",
  "appConfig": {},
  "expectedArtifacts": [
    {
      "defaultArtifact": {
        "kind": "default.github",
        "name": "deploy/namespace.yaml",
        "reference": "https://api.github.com/repos/dippynark/goldengoose/contents/deploy/namespace.yaml",
        "type": "github/file",
        "version": "master"
      },
      "id": "e0f04ff2-9fbc-40e1-b625-e1eccb38bd57",
      "matchArtifact": {
        "kind": "github",
        "name": "deploy/namespace.yaml",
        "type": "github/file"
      },
      "useDefaultArtifact": true,
      "usePriorExecution": false
    },
    {
      "defaultArtifact": {
        "kind": "default.github",
        "name": "deploy/deployment.yaml",
        "reference": "https://api.github.com/repos/dippynark/goldengoose/contents/deploy/deployment.yaml",
        "type": "github/file",
        "version": "master"
      },
      "id": "281173ce-91c3-4e7b-83b3-63a2939c5969",
      "matchArtifact": {
        "kind": "github",
        "name": "deploy/deployment.yaml",
        "type": "github/file"
      },
      "useDefaultArtifact": true,
      "usePriorExecution": false
    },
    {
      "defaultArtifact": {
        "kind": "default.docker",
        "name": "index.docker.io/dippynark/goldengoose",
        "reference": "index.docker.io/dippynark/goldengoose",
        "type": "docker/image",
        "version": "latest"
      },
      "id": "70d2adcf-cbac-47b5-bbea-3b454ceaac0c",
      "matchArtifact": {
        "kind": "docker",
        "name": "index.docker.io/dippynark/goldengoose",
        "type": "docker/image"
      },
      "useDefaultArtifact": true,
      "usePriorArtifact": true,
      "usePriorExecution": false
    },
    {
      "defaultArtifact": {
        "kind": "default.github",
        "name": "deploy/service.yaml",
        "reference": "https://api.github.com/repos/dippynark/goldengoose/contents/deploy/service.yaml",
        "type": "github/file",
        "version": "master"
      },
      "id": "7dc945db-d944-46b9-83e9-fb1329306c7d",
      "matchArtifact": {
        "kind": "github",
        "name": "deploy/service.yaml",
        "type": "github/file"
      },
      "useDefaultArtifact": true,
      "usePriorExecution": false
    },
    {
      "defaultArtifact": {
        "kind": "default.github",
        "name": "deploy/canary.yaml",
        "reference": "https://api.github.com/repos/dippynark/goldengoose/contents/deploy/canary.yaml",
        "type": "github/file",
        "version": "master"
      },
      "id": "53b12e15-6a52-471a-9172-5cad66822e62",
      "matchArtifact": {
        "kind": "github",
        "name": "deploy/canary.yaml",
        "type": "github/file"
      },
      "useDefaultArtifact": true,
      "usePriorArtifact": false,
      "usePriorExecution": false
    }
  ],
  "keepWaitingPipelines": false,
  "lastModifiedBy": "dippynark",
  "limitConcurrent": true,
  "notifications": [],
  "parameterConfig": [],
  "stages": [
    {
      "account": "default",
      "cloudProvider": "kubernetes",
      "manifestArtifactAccount": "github-artifact-account",
      "manifestArtifactId": "e0f04ff2-9fbc-40e1-b625-e1eccb38bd57",
      "moniker": {
        "app": "goldengoose"
      },
      "name": "Deploy namespace",
      "refId": "1",
      "relationships": {
        "loadBalancers": [],
        "securityGroups": []
      },
      "requiredArtifactIds": [],
      "requisiteStageRefIds": [],
      "source": "artifact",
      "type": "deployManifest"
    },
    {
      "account": "default",
      "cloudProvider": "kubernetes",
      "kinds": [],
      "labelSelectors": {
        "selectors": []
      },
      "location": "",
      "manifestArtifactAccount": "github-artifact-account",
      "manifestArtifactId": "281173ce-91c3-4e7b-83b3-63a2939c5969",
      "moniker": {
        "app": "goldengoose"
      },
      "name": "Deploy",
      "options": {
        "cascading": true
      },
      "refId": "2",
      "relationships": {
        "loadBalancers": [],
        "securityGroups": []
      },
      "requiredArtifactIds": [
        "70d2adcf-cbac-47b5-bbea-3b454ceaac0c"
      ],
      "requisiteStageRefIds": [
        "4"
      ],
      "source": "artifact",
      "type": "deployManifest"
    },
    {
      "account": "default",
      "cloudProvider": "kubernetes",
      "kinds": [],
      "labelSelectors": {
        "selectors": []
      },
      "location": "",
      "manifestArtifactAccount": "github-artifact-account",
      "manifestArtifactId": "7dc945db-d944-46b9-83e9-fb1329306c7d",
      "moniker": {
        "app": "goldengoose"
      },
      "name": "Deploy service",
      "options": {
        "cascading": true
      },
      "refId": "3",
      "relationships": {
        "loadBalancers": [],
        "securityGroups": []
      },
      "requisiteStageRefIds": [
        "1"
      ],
      "source": "artifact",
      "type": "deployManifest"
    },
    {
      "analysisType": "realTime",
      "canaryConfig": {
        "beginCanaryAnalysisAfterMins": "1",
        "canaryConfigId": "aec70454-8637-4156-840b-9278f11264e8",
        "combinedCanaryResultStrategy": "LOWEST",
        "lifetimeDuration": "PT0H1M",
        "metricsAccountName": "prometheus-account",
        "scopes": [
          {
            "controlLocation": "goldengoose",
            "controlScope": "baseline",
            "experimentLocation": "goldengoose",
            "experimentScope": "canary",
            "extendedScopeParams": {
              "resourceType": "gce_instance"
            },
            "scopeName": "default",
            "step": 0
          }
        ],
        "scoreThresholds": {
          "marginal": "50",
          "pass": "75"
        },
        "storageAccountName": "google-account"
      },
      "name": "Canary Analysis",
      "refId": "4",
      "requisiteStageRefIds": [
        "5"
      ],
      "type": "kayentaCanary"
    },
    {
      "account": "default",
      "cloudProvider": "kubernetes",
      "expectedArtifacts": [],
      "manifestArtifactAccount": "github-artifact-account",
      "manifestArtifactId": "53b12e15-6a52-471a-9172-5cad66822e62",
      "moniker": {
        "app": "goldengoose"
      },
      "name": "Deploy Canary",
      "refId": "5",
      "relationships": {
        "loadBalancers": [],
        "securityGroups": []
      },
      "requiredArtifactIds": [
        "70d2adcf-cbac-47b5-bbea-3b454ceaac0c"
      ],
      "requisiteStageRefIds": [
        "3"
      ],
      "source": "artifact",
      "type": "deployManifest"
    }
  ],
  "triggers": [
    {
      "account": "dockerhub",
      "enabled": true,
      "organization": "dippynark",
      "registry": "index.docker.io",
      "repository": "dippynark/goldengoose",
      "type": "docker"
    }
  ],
  "updateTs": "1541290580149"
}