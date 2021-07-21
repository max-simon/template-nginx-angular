# Angular + nginx

This repository shows how to containerize an Angular application using a nginx server.

## Getting Started

Clone the repository and run `npm install`.

## Local Development

Like any other Angular application, the application can be served and built locally using `ng serve` and `ng build`. Further details on Angular development can be found [here](https://angular.io/guide/setup-local).

## Build image

To bundle the application files together with an nginx server, run
```
docker build -t angular-app .
```
You can set the following build arguments:
- `SKIP_TESTS`: if set to `true` tests are not executed. Tests can be time consuming because they require a headless chrome (default `false`).
- `APPLICATION`: choose the application (in subfolder `projects`) to serve (default `main`)

## Dynamic Configuration

Sometimes you want to change configuration data without rebuilding the image. The `AppConfig` service loads a configuration file during runtime. The file is located in `assets/config.json` and can be overwritten by e.g. ConfigMap objects.

## CI / CD

### Using OpenShift new-app

Deploy this application to OpenShift by running the following command in the correct namespace:

```
    oc new-app --name <application name> <Git URL>
```

This will set up a BuildConfig, an ImageStream, a Deployment and a Service. To change build arguments, modify the BuildConfig resource accordingly.

You might want to expose the service in order to access it with an external URL:

```
    oc expose svc <application name>
``` 

In order to use a ConfigMap for dynamic configuration of the application (see above), you need to run the following commands:

1. Create a ConfigMap from a custom configuration file:
```
    oc create configmap <configmap name> --from-file config.json=<path to custom config json file>
```
2. Mount the ConfigMap to the specified path in the pods:
```
    oc set volume deployment/<application name> --add --type configmap --configmap-name <configmap name> --mount-path /opt/app-root/src/assets/
```

### Using Pipeline and Helm

#### Setup the Pipeline

The steps to setup a CI pipeline are described in [tekton](tekton).

#### Deploy a Helm chart

To deploy the application using `helm` you need to set the image repository (`image.repository`) and tag (`image.tag`)
```
    helm install <app-name> chart/base --set image.repository=<image repository uri> --set image.tag=<image tag>
```
If you use an OpenShift ImageStream, you might also want to set a trigger to automatically redeploy as soon as an image is pushed to the ImageStream:
```
    ... --set --set imageStreamTagTrigger.enabled=true --set imageStreamTagTrigger.name=<image stream name>:<image stream tag> --set imageStreamTagTrigger.namespace=<namespace of image stream>
```
If the Deployment and ImageStream are in different namespaces, make sure that the service accounts can pull from the ImageStream:
```
    oc policy add-role-to-group system:image-puller system:serviceaccounts:<namespace of deployment> --namespace=<namespace of imagestream>
```

## License

This sample application is licensed under the Apache License, Version 2. Separate third-party code objects invoked within this code pattern are licensed by their respective providers pursuant to their own separate licenses. Contributions are subject to the [Developer Certificate of Origin, Version 1.1](https://developercertificate.org/) and the [Apache License, Version 2](https://www.apache.org/licenses/LICENSE-2.0.txt).

[Apache License FAQ](https://www.apache.org/foundation/license-faq.html#WhatDoesItMEAN)