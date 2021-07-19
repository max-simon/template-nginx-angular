# Angular Application with NGINX

## Deployment

You can deploy this application to OpenShift using
```
    oc new-app --name <application name> <Git URL>
```

## Configuration File

The `AppConfig` service loads a configuration file during runtime. This allows to dynamically set configuration data. The file is located in `assets/config.json`. This can be overwritten in OpenShift with a ConfigMap:

1. Create a config map from a custom configuration file:
```
    oc create configmap <configmap name> --from-file config.json=<path to custom config file>
```
2. Mount the ConfigMap to the specified path:
```
    oc set volume deployment/<application name> --add --type configmap --configmap-name <configmap name> --mount-path /opt/app-root/src/assets/
```A test
