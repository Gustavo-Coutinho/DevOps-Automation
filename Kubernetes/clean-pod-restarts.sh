# Obter todos os namespaces QUE NÃO SEJAM DO SISTEMA e armazenar seus nomes, namespaces e réplicas em um array
declare -a deployments
all_deployments=($(kubectl get deployments --all-namespaces -o custom-columns=NAME:.metadata.name,NAMESPACE:.metadata.namespace,REPLICAS:.spec.replicas --no-headers | grep -v kube-system | grep -v monitoring | grep -v cert-manager))

# Percorrer o array e executar a limpeza de pods com contagem de restart acima de 0:
for ((i = 0; i < ${#all_deployments[@]}; i += 3)); do
  deployment=${all_deployments[$i]}
  namespace=${all_deployments[$i+1]}
  echo "Namespace: $namespace. Serão excluídos os deployments: $(kubectl get pods -n $namespace | awk '$4>0 {print $1}')"
  kubectl delete pod -n $namespace $(kubectl get pods -n $namespace | awk '$4>0 {print $1}')
done
