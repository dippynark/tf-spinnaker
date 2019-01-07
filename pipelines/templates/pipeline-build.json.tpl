{
  "name": "Build",
  "application": "goldengoose",
  "id": "UUID",
  "appConfig": {},
  "expectedArtifacts": [],
  "keepWaitingPipelines": false,
  "lastModifiedBy": "dippynark",
  "limitConcurrent": true,
  "parameterConfig": [
    {
      "default": "${trigger['hash']}",
      "description": "Commit hash",
      "hasOptions": false,
      "name": "hash",
      "options": [
        {
          "value": ""
        }
      ],
      "required": true
    }
  ],
  "stages": [
    {
      "account": "default",
      "cloudProvider": "kubernetes",
      "manifestArtifactAccount": "embedded-artifact",
      "manifests": [
        {
          "apiVersion": "build.knative.dev/v1alpha1",
          "kind": "Build",
          "metadata": {
            "annotations": {
              "strategy.spinnaker.io/max-version-history": "1",
              "strategy.spinnaker.io/versioned": "true"
            },
            "name": "goldengoose-build",
            "namespace": "goldengoose"
          },
          "spec": {
            "serviceAccountName": "docker-dippynark",
            "source": {
              "git": {
                "revision": "master",
                "url": "https://github.com/dippynark/goldengoose.git"
              }
            },
            "steps": [
              {
                "args": [
                  "checkout",
                  "${parameters['hash']}"
                ],
                "image": "alpine/git",
                "name": "git-checkout"
              },
              {
                "args": [
                  "docker",
                  "build",
                  "-t",
                  "dippynark/goldengoose:${parameters['hash']}",
                  "/workspace"
                ],
                "image": "docker",
                "name": "docker-build",
                "volumeMounts": [
                  {
                    "mountPath": "/var/run/docker.sock",
                    "name": "docker-socket"
                  }
                ]
              },
              {
                "args": [
                  "docker",
                  "push",
                  "dippynark/goldengoose:${parameters['hash']}"
                ],
                "image": "docker",
                "name": "docker-push",
                "volumeMounts": [
                  {
                    "mountPath": "/var/run/docker.sock",
                    "name": "docker-socket"
                  }
                ]
              }
            ],
            "volumes": [
              {
                "hostPath": {
                  "path": "/var/run/docker.sock",
                  "type": "Socket"
                },
                "name": "docker-socket"
              }
            ]
          }
        }
      ],
      "moniker": {
        "app": "goldengoose"
      },
      "name": "Build",
      "refId": "1",
      "relationships": {
        "loadBalancers": [],
        "securityGroups": []
      },
      "requisiteStageRefIds": [],
      "source": "text",
      "type": "deployManifest"
    }
  ],
  "triggers": [
    {
      "branch": "master",
      "enabled": true,
      "project": "dippynark",
      "secret": "Gaf1ohwiloh0iegheiqu",
      "slug": "goldengoose",
      "source": "github",
      "type": "git"
    }
  ],
  "updateTs": "1546876838227"
}