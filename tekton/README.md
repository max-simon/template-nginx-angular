# Setup a Pipeline

## Create ImageStream

This step is not required if you plan to use an external image registry.

Create an ImageStream in OpenShift:
```
    oc create imagestream <is-name>
```

Get the URI of the ImageStream by running:
```
    oc get imagestream <is-name> -o jsonpath="{.status.dockerImageRepository}"
```

If the ImageStream is in a different project than the deployment or the pipeline, allow the access to the namespace of the imagestream by running
```
    oc policy add-role-to-group system:image-puller system:serviceaccounts:<namespace of deployment> --namespace=<namespace of imagestream>
```
and 
```
    oc policy add-role-to-group system:image-pusher system:serviceaccounts:<namespace of pipeline> --namespace=<namespace of imagestream>
```

## Create Pipeline resources

The `buildah` images requires root access (unless the host configures `/sys/proc/max_user_namespaces` accordingly). Therefore, you need to allow the `pipeline` serviceaccount to create privileged containers by running
```
    oc adm policy add-scc-to-user privileged -z pipeline
```

You can create the following resources by running 
```
    oc process -f pipeline-template.yml -p GIT_URL=<git url> -p GIT_REVISION=<git revision> -p OUTPUT_REGISTRY=<uri of registry, e.g. image stream from before> | oc create -f -
```

If you want to have multiple pipelines in the same namespace, e.g. for different git revisions, also set `-p POSTFIX=<some identifier>`

### Input

The input to the pipeline is a Git reference (URL and revision). The template creates a PipelineResource of type `git` for this. OpenShift automatically pulls the repository and provide it as input to the pipeline.

### Output

The output of the pipeline - the final image - is pushed to a registry (internal or external). The registry is referenced in a PipelineResource of type `image` which is created by the template.

### Task and Pipeline

A pipeline consists of multiple tasks, each task consists of multiple steps. Because sharing files between tasks require a persistent volume, all required steps are in a single task only.\
The following steps are executed:
- `copy-files`: the input (Git pull source code) is read-only, therefore we need to copy it to a different location
- `npm-install`: run `npm install` to install all required dependencies
- `npm-test`: run the provided npm script to test the application. Because testing requires Chrome and the installation in Red Hat Node images is very difficult, this runs on standard node image.
- `npm-build`: run the provided npm script to build the application. Also add the config files for nginx to the correct location
- `container-create-dockerfile`: use s2i to create a Dockerfile for the final image, save also the required files in the correct folder structure
- `container-build`: use the generated Dockerfile to build the final image
- `container-push`: push the final image to the provided output registry

### Trigger

In order to trigger the pipeline using a webhook, three resources are required:
- TriggerTemplate: this resource defines how the triggered pipeline run should look like (i.e. which input and output resources it should use)
- EventListener: this resource spins up a pod (and a service) which listen to requests. Upon a request they execute a predefined trigger. The `default` does not have sufficient permissions to run this, therefore use another service account.
- Route: this is a public route to expose the service of the EventListener

