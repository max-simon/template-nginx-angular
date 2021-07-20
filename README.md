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
- `CONFIGURATION`: choose the configuration specified in `angular.json` (default `production`)
- `APPLICATION`: choose the application (in subfolder `projects`) to serve (default `main`)

## Dynamic Configuration

Sometimes you want to change configuration data without rebuilding the image. The `AppConfig` service loads a configuration file during runtime. The file is located in `assets/config.json` and can be overwritten by e.g. ConfigMap objects.

## Deployment

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

### Using Helm

Set the correct Git URL and reference (branch/tag) in `values.yaml` (in `git` object). You can also modify the build arguments there (in `buildConfig` object). Afterwards, install the application to OpenShift using
```
    helm install <application name> chart/base
```

and trigger a new build using
```
    oc start-build <build config name>
```