#!/bin/bash

cat <<EOF > yamls/geoserver-pvc.yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: geoserver-pro-pvc
  namespace: $NAMESPACE
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
  storageClassName: gluster-heketi
EOF
cat yamls/geoserver-pvc.yaml

cat <<EOF > yamls/postgis-pvc.yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: postgis-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: gluster-heketi
EOF
cat yamls/postgis-pvc.yaml

cat <<EOF >  yamls/postgis-rc.yaml
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: postgis-gs
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      name: postgis-gs
  template:
    metadata:
      labels:
        name: postgis-gs
    spec:
      containers:
      - name: postgis-default
        image: mdillon/postgis:9.6-alpine
        imagePullPolicy: IfNotPresent
        env:
        - name: POSTGRES_PASSWORD
          value: "root"
        - name: POSTGRES_USER
          value: "tdtjskfb402"
        ports:
        - name: postgis
          containerPort: 5432
        volumeMounts:
        - name: default-postgis
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: default-postgis
        persistentVolumeClaim:
          claimName: postgis-pvc
EOF
cat yamls/postgis-rc.yaml


cat <<EOF >  yamls/geoserver-rc.yaml
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: geoserver-node
  namespace: $NAMESPACE
spec:
  replicas: 2
  selector:
    matchLabels:
      name: geoserver-node
  template:
    metadata:
      labels:
        name: geoserver-node
    spec:
      containers:
      - name: geoserver-node
        image: $REGISTRY_URL/gis/geoserver:$IMAGE_TAG
        ports:
        - name: tomcat-default
          containerPort: 8080
        readinessProbe:
          httpGet:
            path: /geoserver/web/wicket/bookmarkable/org.geoserver.web.demo.MapPreviewPage
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 10
          timeoutSeconds: 1,
          periodSeconds: 10,
          successThreshold: 1,
          failureThreshold: 3
        livenessProbe:
          httpGet:
            path: /geoserver/web
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 20
          timeoutSeconds: 1,
          periodSeconds: 10,
          successThreshold: 1,
          failureThreshold: 3
        volumeMounts:
        - name: data-dir
          mountPath: /root/data
        - name: webxml
          mountPath: /usr/local/tomcat/webapps/geoserver/WEB-INF/web.xml
          subPath: web.xml
        - name: jdbcconfig
          mountPath: /root/data/jdbcconfig/jdbcconfig.properties
          subPath: jdbcconfig.properties
        - name: jdbcstore
          mountPath: /root/data/jdbcstore/jdbcstore.properties
          subPath: jdbcstore.properties
        imagePullPolicy: IfNotPresent
      volumes:
      - name: data-dir
        persistentVolumeClaim:
          claimName: geoserver-pro-pvc
      - name: webxml
        configMap:
          name: geoserver-config
          items:
          - key: web.xml
            path: web.xml
      - name: jdbcconfig
        configMap:
          name: geoserver-config
          items:
          - key: jdbcconfig.properties
            path: jdbcconfig.properties
      - name: jdbcstore
        configMap:
          name: geoserver-config
          items:
          - key: jdbcstore.properties
            path: jdbcstore.properties

EOF
cat yamls/geoserver-rc.yaml

cat <<EOF >  yamls/geoserver-sv.yaml
apiVersion: v1
kind: Service
metadata:
  name: geoserver
  namespace: $NAMESPACE
spec:
  type: "NodePort"
  ports:
  - name: tomcat-default
    port: 8080
    targetPort: 8080
  selector:
    name: geoserver-node
  sessionAffinity: "ClientIP"
EOF
cat  yamls/geoserver-sv.yaml


cat <<EOF >  yamls/postgis-sv.yaml
apiVersion: v1
kind: Service
metadata:
  name: postgis-gs
  namespace: $NAMESPACE
spec:
  type: "ClusterIP"
  ports:
  - name: postgis
    port: 5432
    targetPort: 5432
  selector:
    name: postgis-gs
  sessionAffinity: "ClientIP"
EOF
cat  yamls/postgis-sv.yaml


