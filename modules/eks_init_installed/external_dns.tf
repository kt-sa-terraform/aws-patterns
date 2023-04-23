resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.12.2"
  namespace  = "kube-controller"

#values is array format but when use <<delimiter, it will treat content block as a single element, until delimiter is reached. So we need define values in format of yaml exacly

  values = [<<VALUES
# Default values for external-dns.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

image:
  repository: k8s.gcr.io/external-dns/external-dns
  # Overrides the image tag whose default is v{{ .Chart.AppVersion }}
  tag: ""
  pullPolicy: IfNotPresent

imagePullSecrets: []

nameOverride: "external-dns"
fullnameOverride: "external-dns"

commonLabels: {}

serviceAccount:
  # Specifies whether a service account should be created
  create: true
  # Annotations to add to the service account
  annotations: {}
  # The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name: ""

rbac:
  # Specifies whether RBAC resources should be created
  create: true
  additionalPermissions: []

# Annotations to add to the Deployment
deploymentAnnotations: {}

podLabels: {}

# Annotations to add to the Pod
podAnnotations:
  iam.amazonaws.com/role: "${var.eks_external_route53dns_role}"
shareProcessNamespace: false

podSecurityContext:
  fsGroup: 65534

securityContext:
  runAsNonRoot: true
  runAsUser: 65534
  readOnlyRootFilesystem: true
  capabilities:
    drop: ["ALL"]

priorityClassName: ""

terminationGracePeriodSeconds:

serviceMonitor:
  enabled: false
  additionalLabels: {}
  interval: 1m
  scrapeTimeout: 10s

env: []

livenessProbe:
  httpGet:
    path: /healthz
    port: http
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 2
  successThreshold: 1

readinessProbe:
  httpGet:
    path: /healthz
    port: http
  initialDelaySeconds: 5
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 6
  successThreshold: 1

service:
  port: 7979
  annotations: {}

extraVolumes: []

extraVolumeMounts: []

resources: {}

nodeSelector: {}

tolerations: []

affinity: {}

topologySpreadConstraints: []

logLevel: info
logFormat: text

interval: 1m
triggerLoopOnEvent: false

sources:
  - service
  - ingress

policy: upsert-only

#registry: txt
#txtOwnerId: ""
#txtPrefix: ""
#txtSuffix: ""

domainFilters: ["${var.internal_domain}"]

provider: aws

extraArgs: []
VALUES

]
  depends_on = [
    kubernetes_namespace.default_namespace
  ]
}
