# Docker-scanning-CI-CD-pipeline

## Overview
The CI/CD Docker Static Vulnerability analysis project will automatically detect changes to a Dockerfile and employ the use of SAST tools to identify vulnerabilities in the Dockerfile then use  a Vulnerability Management Platform.

<img src="./Pictures/Project_Overview.jpg">

- [Prerequisites](#prerequisites)
- [Installing Code Ready Containers](#installing-code-ready-containers)
  - [Starting the OpenShift container platform](#starting-the-openshift-container-platform)
- [Installing Helm](#installing-helm)
  - [Deploying the DefectDojo Helm chart](#deploying-the-defectdojo-helm-chart)
  - [Deploying Gitea Helm chart](#deploying-gitea-helm-chart)
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

**Note** For Windows installation you must enable Hyper-X from the "Enable/Disable Windows Features" tab.

<img src="./Pictures/Windows_Features.jpg">

RedHat provides [this](https://crc.dev/crc/#installing-codeready-containers_gsg) installation guide

### Starting the OpenShift container platform 
After installing Code ready Containers
```console 
crc setup
```

```console 
crc start -c 4 -m 16384
```

The expected output of this command
```console
Started the OpenShift cluster. 

The server is accessible via web console at: 

  https://console-openshift-console.apps-crc.testing 

  
Log in as administrator: 

  Username: kubeadmin 

  Password: <kubeadmin_password>

Log in as user: 

  Username: developer 

  Password: developer 

Use the 'oc' command line interface: 

  PS> & crc oc-env | Invoke-Expression 

  PS> oc login -u developer https://api.crc.testing:6443 
```
You can navigate to the OpenShift web console by navigating to *https://api.crc.testing:6443* or by performing ```console crc console```

<img src="./Pictures/CRC_Console.jpg">

If you encounter this error whilst trying to start crc 
```console
failed to expose port :2222 -> 192.168.127.2:22: listen tcp :2222: bind: An attempt was made to access a socket in a way forbidden by its access permissions. 
```
**NOTE** The port in this example is *2222* however this solution is applicable to any port number referenced in this error.

You need to disable Hyper-X in Windows Features

Then reserve the port by opening PowerShell with *Administrator* rights and performing
```console 
netsh int ipv4 add excludedportrange protocol=tcp startport=2222 numberofports=1
```

Finally enable Hyper-V and restart your system, then run `crc setup` and `crc start`.


**Note** You must shutdown cluster safetly by performing 
```console
crc stop 
``` 

The expected output is as follows:
```console
INFO Stopping kubelet and all containers... 

INFO Stopping the OpenShift cluster, this may take a few minutes... 

Stopped the OpenShift cluster 
```

## Installing Helm 

If installing on Windows ([chocolatey](https://chocolatey.org/install)): 
```console
choco install kubernetes-helm
```

If installing on MacOS (brew):
```console
brew install helm
```
If installing on Debian/Ubuntu (APT):
```console
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

### Deploying the DefectDojo Helm chart

## Upstream changes 

This chart is developed and maintained by the DefectDojo Community, the original chart can be found [here](https://github.com/DefectDojo/django-DefectDojo/tree/master/helm/defectdojo)
A collection of changes have been made to this chart to make it compliant when deployed on the OpenShift Environment which can be viewed [here](./Backend/DefectDojo/chart/README.md#upstream-changes)

## Installation

Ensure you are in the directory that contains the helm chart by performing:
```console
cd secure-Docker-dev-CI-CD-pipeline-main/Backend/DefectDojo/chart/ 
```

Update the *host* value in DefectDojo's [helm chart](/Backend/DefectDojo/chart/values.yaml). This is the name of the URL that you will assign to your DefectDojo instance.
**NOTE**
If you are using Code Ready Containers the domain for exposed applications is *apps-crc.testing*.
```console
database: postgresql
host: defectdojo-route.app-crc.testing # replace this with your DefectDojo-URL.YourDomain
imagePullPolicy: Always
# Where to pull the defectDojo images from. Defaults to "defectdojo/*" repositories on hub.docker.com
repositoryPrefix: defectdojo
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
....

oc delete secret defectdojo-postgresql-specific defectdojo-rabbitmq-specific
```

All pods should begin starting up, you can confirm this by performing
```console 
oc get pods -n <namespace-you-deployed-defectdojo>
```

Once the initializer pod has finished you can access the DefectDojo UI via your specified route, you can retrieve the credentials by navigating to the Secrets tab in Openshift -> <release_name>- 
or by performing 

```console
.
```
<img src="./Pictures/DD_WebUI.jpg">

### Deploying Gitea Helm chart
Gitea is a self-hosted git service, you can read more about Gitea [here](https://docs.gitea.io/en-us/)

## Upstream changes 

This chart is developed and maintained by the Gitea Community, the original chart can be found [here](https://gitea.com/gitea/helm-chart/)
A collection of changes have been made to this chart to make it compliant when deployed on the OpenShift Environment which can be viewed [here](./Backend/Gitea/chart/README.md#upstream-changes)

## Installation

Install Gitea from the command line by performing
```console
cd secure-Docker-dev-CI-CD-pipeline-main/Backend/Gitea/chart/ 

helm install <release_name> ./
```

Once Gitea is running you can setup a [repository](#github-webhooks)

## Installing OpenShift Pipelines

### Installing using the Web Console

Whilst logged into the OpenShift Web console navigate to the **Operators** tab
<img src="./Pictures/OS_Operators.jpg"> -->

<img src="./Pictures/OS_Pipelines.jpg">

<img src="./Pictures/OS_Pipelines_Success.jpg">

### Installing using the CLI 

OpenShift can also be deployed using the [subscription](./Pipeline/OpenShift-Pipelines/subscription.yaml) template.

```console
oc create -f subscription.yaml
```

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
oc create -f ci-cd-pipeline.yaml
```

#### Secret
Input the API key for the admin user, you can retrieve this whilst logged into the DefectDojo Web UI and navigating to OpenAPIV2 
<img src="./Pictures/DD_LoggedIn.jpg">

<img src="./Pictures/DD_APIKeyV2.jpg">
```console
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
```console
apiVersion: v1
kind: ConfigMap
metadata:
  name: dojo-configmap
  namespace: default
data:
  dojo-configmap.url: https://<release_name>.yourDomain # e.g https://defectdojo-route.app-crc.testing/
```

#### PipelineResource
```console
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: <resource_name>
spec:
  type: git
  params:
    - name: url
      value: '<url>' # this is the URL of you Git Repository in Gitea ..?
    - name: revision
      value: main # this is the default revision branch of you repository unless configured otherwise this is main or master.
 ```
 
You can the deploy the PipelineResource by performing:

```console
oc create -f pipelineresouce.yaml
```

#### PipelineRun

## Deploying Tekton Triggers


A description of the Tekton Trigger configurations is described [here](./webhook/README.md)

```console
# Deploy the role based access control
oc create -f rbac.yaml 

# Deploy the trigger template
oc create -f triggertemplate.yaml

# Deploy the trigger binding
oc create  -f triggerbinding.yaml

# Deploy the Eventlistner
oc create -f EventListener.yaml
```

### GitHub Webhooks

If you are hosting this pipeline in an internal environment (using CRC) then follow the guide for [Setting up Gitea](#setting-up-gitea)

In the GitHub Repo that you wish to use navigate to Settings > Webhooks and input the Eventlistner URL from above.

### Setting up Gitea

Once Gitea has been deployed, navigate to the application using your specified route. (https://gitea-route.apps-testing.crc)

To create a Gitea Migration select "+" -> "New Migration"
<img src="./Pictures/New_Migration_Gitea.png"> 


Select GitHub.
<img src="./Pictures/Migration_Platform_Gitea.png">


Input the URL for the GitHub repository you are migrating from.

**Note** it is recommended for itegrity accross platforms that you set up a **mirrored** repository, if you choose not to then do not tick the option "This repository will be a mirror" seen below
<img src="./Pictures/Migration_Gitea.png">


To setup a webhook for the newly created Gitea Repository navigate to Settings -> Webhooks
<img src="./Pictures/Gitea_Dashboard.png">


Select "Add Webhook" and "Gitea" from the drop down menu
<img src="./Pictures/Gitea_webhook_setup.png">


Input your EventListener URL into the "Target URL" field and ensure that "POST Content Type" is set to "application/json"
<img src="./Pictures/Gitea_Webhook.png">


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

