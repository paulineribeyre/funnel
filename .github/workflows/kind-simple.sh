#!/usr/bin/env bash
set -euo pipefail
# ---------------- Config ----------------
CLUSTER_NAME=${CLUSTER_NAME:-mountpoint-s3-csi}
K8S_VERSION=${K8S_VERSION:-v1.35.0}
NODE_IMAGE=${NODE_IMAGE:-kindest/node:${K8S_VERSION}}
# AWS_PROFILE=${AWS_PROFILE:-jawiz}
# S3_BUCKET=${S3_BUCKET:?You must set S3_BUCKET to a real S3 bucket name}
# TIMEOUT_SECONDS=${TIMEOUT_SECONDS:-240}


if kubectl config current-context >/dev/null 2>&1 && kubectl config current-context | grep -q '^kind-'; then
  echo "♻️ Using existing kind context: $(kubectl config current-context)"
elif kind get clusters | grep -q .; then
  CLUSTER_NAME=$(kind get clusters | head -n1)
  echo "♻️ Switching to existing kind cluster: $CLUSTER_NAME"
  kubectl config use-context "kind-$CLUSTER_NAME"
else
  echo "🚀 Creating kind cluster: $CLUSTER_NAME"
  cat <<EOF | kind create cluster --name "$CLUSTER_NAME" --image "$NODE_IMAGE" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
EOF
fi
kubectl wait --for=condition=Ready nodes --all --timeout=180s




helm repo add gen3 https://helm.gen3.org
# helm upgrade --install aws-mountpoint-s3-csi-driver \
#   --namespace kube-system \
#   --create-namespace \
#   --set awsAccessSecret.name=aws-secret \
#   aws-mountpoint-s3-csi-driver/aws-mountpoint-s3-csi-driver
# kubectl rollout status deployment/s3-csi-controller -n kube-system --timeout=180s
# kubectl wait pods -n kube-system \
#   -l app.kubernetes.io/name=aws-mountpoint-s3-csi-driver \
#   --for=condition=Ready --timeout=180s

helm upgrade --install gen3 gen3/gen3 -f .github/values.yaml
