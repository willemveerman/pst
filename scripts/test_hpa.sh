#!/bin/bash

INITIAL_PODS=$(kubectl get pods --no-headers | wc -l)

kubectl port-forward svc/pstest 5000:5000 &

sleep 3

for i in {1..150}
do
  curl localhost:5000/products
  echo ""
  echo ""
  echo "-----"
  echo "$i"
  sleep 0.1
done

pkill kubectl -9

FINAL_PODS=$(kubectl get pods --no-headers | wc -l)

echo ""
echo "-----"
echo "-----"
echo "-----"
echo ""
echo "INITIAL: $INITIAL_PODS"
echo "FINAL: $FINAL_PODS"

