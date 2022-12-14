#!/usr/bin/env bash

AWS_REGION="us-east-1"
EKS_CLUSTER_NAME="eks-demo"

# CHART VERSION	APP VERSION
# ---------------------------
# CHART VERSION	APP VERSION
# 0.20.2       	1.18.2      # ref: https://github.com/aws/aws-node-termination-handler/releases/tag/v1.18.2
# 0.20.1       	1.18.1      # ref: https://github.com/aws/aws-node-termination-handler/releases/tag/v1.18.1
# 0.20.0       	1.18.0      # ref: https://github.com/aws/aws-node-termination-handler/releases/tag/v1.18.0
# 0.19.3       	1.17.3      # ref: https://github.com/aws/aws-node-termination-handler/releases/tag/v1.17.3

# APP_VERSION="1.18.2"
CHART_VERSION="0.20.2"

echo "[debug] detecting chart repo existance"
helm repo list | grep -q 'eks-charts'

if [ $? -ne 0 ]; then
  echo "[debug] setup chart repo"
  helm repo add eks https://aws.github.io/eks-charts || true
else
  echo "[debug] found chart repo"
fi

echo "[debug] helm repo update"
helm repo update eks

echo "[debug] detecting Helm resource existance"
helm list --all-namespaces | grep -q 'aws-node-termination-handler'

# TODO: nice to have regional image setup
echo "[debug] setup eks/aws-node-termination-handler"
helm upgrade \
  --create-namespace \
  --namespace aws-node-termination-handler \
  --install aws-node-termination-handler \
  --version ${CHART_VERSION} \
  eks/aws-node-termination-handler \
    --set enableSpotInterruptionDraining="true" \
    --set enableRebalanceMonitoring="true" \
    --set enableRebalanceDraining="true" \
    --set enableScheduledEventDraining="true" \
    --set nodeSelector."eks\.amazonaws\.com/capacityType"=SPOT
   # --set nodeSelector."karpenter\.sh/capacity-type"=spot

echo "[debug] listing installed"
helm list --all-namespaces --filter aws-node-termination-handler
