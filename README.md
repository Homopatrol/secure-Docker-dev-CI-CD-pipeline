# Docker-scanning-CI-CD-pipeline

## Overview

<!-- <img src="https://github.com/Homopatrol/secure-Docker-dev-CI-CD-pipeline/blob/main/Pictures/pipeline_overview.jpg"> -->

- [Prerequisites](#prerequisites)
- [Installing Code Ready Containers](#installing-code-ready-containers)
  - [Starting the OpenShift container platform](#starting-the-openshift-container-platform)
- [Installing Helm](#installing-helm)
  - [Deploying the DefectDojo Helm chart](#deploying-the-defectdojo-helm-chart)
- [Installing OpenShift Pipelines](#installing-openshift-pipelines)
- [Deploying CI/CD Pipeline Components](#deploying-ci/cd-pipeline-components)
- [Deploying Tekton Triggers](#deploying-tekton-triggers)
- [Uninstalling](#uninstalling)

## Prerequisites

Prior to deploying the CI/CD Docker Pipeline you must download or clone this Repository, you can do this by performing:

```console
git clone https://github.com/Homopatrol/secure-Docker-dev-CI-CD-pipeline.git
```

The system that the CI/CD Docker Pipeline will be deployed on requires the following system resources in order to run Code Ready Containers:
   
 - 4 physical CPU cores
 - 9 GB of free memory
 - 35 GB of storage space

## Installing Code Ready Containers

RedHat provides [this](https://crc.dev/crc/#installing-codeready-containers_gsg) installation guide

### Starting the OpenShift container platform 
After installing Code ready Containers
```console 
crc setup
```

```console 
crc start -c 4 -m 16384
```

**Note** You must shutdown cluster safetly by performing 
```console
crc stop
```
## Installing Helm 

```console
# if using Windows (chocolatey)
choco install kubernetes-helm

# if using MacOS (brew)
brew install helm

# if using Debian/Ubuntu (APT)
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

### Deploying the DefectDojo Helm chart


Ensure you are in the directory that contains the helm chart by performing:
```console
cd secure-Docker-dev-CI-CD-pipeline-main/Backend/DefectDojo/chart/ 
```

```console
helm install <release_name> ./
```

**Note** 
If you are re-installing DefectDojo you must ensure there is no remaning resources from the previous DefectDojo instance.
You can do this by peforming:
```console
oc get pvc

oc delete pvc <release_name>-pvc

----------------------

oc get secret

Name 
------
defectdojo-postgresql-specific
defectdojo-rabbitmq-specific

oc delete secret defectdojo-postgresql-specific defectdojo-rabbitmq-specific
```

## Installing OpenShift Pipelines

Whilst logged into the OpenShift Web console navigate to the **Operators** tab

### Deploying CI/CD Pipeline Components

Ensure you are deploying the pipeline components in the correct namespace:
```console
oc project openshift-pipelines
```
#### Task
```console
oc create -f kics-task.yaml
oc create -f checkov-task.yaml
```
#### Pipeline
```console
oc create -f Pipeline.yaml
```

#### Secret
```
apiVersion: v1
kind: Secret
metadata:
  name: dojo-secret
  namespace: default
type: Opaque
stringData:
  dojo-secret.username: admin
  dojo-secret.apikey: <>
```

#### ConfigMap
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: dojo-configmap
  namespace: default
data:
  dojo-configmap.url: http://<relrease_name>-defectdojo-django.default.svc.cluster.local
```

#### PipelineResource

```
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: <resource_name>
spec:
  type: git
  params:
    - name: url
      value: '<url>' # this is the URL of you GitHub Repository 
    - name: revision
      value: main # this is the default revision branch of you repository unless configured otherwise this is main or master.
 ```
 
You can the deploy the PipelineResource by performing:

```console
oc create -f pipelineresouce.yaml
```

#### PipelineRun

## Deploying Tekton Triggers

## Uninstalling
To uninstall any of the pipeline resources run:

```console
oc delete -f <resource_name>.yaml
```

To uninstall the DefectDojo application run:
```console
helm list



helm uninstall <release_name>
```

