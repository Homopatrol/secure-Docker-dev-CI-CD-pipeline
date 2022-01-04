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
Download or clone this Repository performing 
```console
git clone https://github.com/Homopatrol/secure-Docker-dev-CI-CD-pipeline.git
```

## Installing Code Ready Containers

RedHat provides [this](https://crc.dev/crc/) installation guide

### Starting the OpenShift container platform 

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
#### PipelineResource

```console
oc create -f pipelineresouce.yaml
```

## Deploying Tekton Triggers

## Uninstalling

```console
oc delete -f <resource_name>.yaml
```

