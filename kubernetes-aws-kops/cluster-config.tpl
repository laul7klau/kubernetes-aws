apiVersion: kops.k8s.io/v1alpha2
kind: Cluster
metadata:
  creationTimestamp: "2021-05-04T10:24:12Z"
  generation: 1
  name: {{NAME}}
spec:
  api:
    loadBalancer:
      class: Classic
      type: Public
  authorization:
    rbac: {}
  channel: stable
  cloudProvider: aws
  configBase: s3://{{NAME}}
  containerRuntime: containerd
  etcdClusters:
  - cpuRequest: 200m
    etcdMembers:
    - encryptedVolume: true
      instanceGroup: master-us-west-2a
      name: a
    memoryRequest: 100Mi
    name: main
  - cpuRequest: 100m
    etcdMembers:
    - encryptedVolume: true
      instanceGroup: master-us-west-2a
      name: a
    memoryRequest: 100Mi
    name: events
  iam:
    allowContainerRegistry: true
    legacy: false
  kubelet:
    anonymousAuth: false
  kubernetesApiAccess:
  - 0.0.0.0/0
  kubernetesVersion: 1.20.6
  masterInternalName: api.internal.{{NAME}}
  masterPublicName: api.{{NAME}}
  networkCIDR: 172.20.0.0/16
  #networking:
  #  flannel:
  #    backend: vxlan
  #nonMasqueradeCIDR: 10.244.0.0/16 # NonMasqueradeCIDR is the CIDR for the internal k8s network (on which pods & services live). Must not overlap with networkCIDR.
  nonMasqueradeCIDR: 10.244.0.0/16 # NonMasqueradeCIDR is the CIDR for the internal k8s network (on which pods & services live). Must not overlap with networkCIDR.
  sshAccess:
  - 0.0.0.0/0
  subnets:
  - cidr: 172.20.32.0/19
    name: us-west-2a
    type: Public
    zone: us-west-2a
  topology:
    dns:
      type: Public
    masters: public
    nodes: public

---

apiVersion: kops.k8s.io/v1alpha2
kind: InstanceGroup
metadata:
  creationTimestamp: "2021-05-04T10:24:13Z"
  labels:
    kops.k8s.io/cluster: {{NAME}} 
  name: master-us-west-2a
spec:
  image: 099720109477/ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20210415
  machineType: t3.xlarge
  maxSize: 1
  minSize: 1
  nodeLabels:
    kops.k8s.io/instancegroup: master-us-west-2a
  role: Master
  subnets:
  - us-west-2a

---

apiVersion: kops.k8s.io/v1alpha2
kind: InstanceGroup
metadata:
  creationTimestamp: "2021-05-04T10:24:13Z"
  labels:
    kops.k8s.io/cluster: {{NAME}} 
  name: nodes-us-west-2a
spec:
  image: 099720109477/ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20210415
  machineType: t3.medium
  maxSize: 3
  minSize: 3
  nodeLabels:
    kops.k8s.io/instancegroup: nodes-us-west-2a
  role: Node
  subnets:
  - us-west-2a
