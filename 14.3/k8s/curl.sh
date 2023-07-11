#!/bin/bash

#frontend2any
echo -e "\033[35m check access frontend2backend \033[m" 
microk8s kubectl exec deployments/frontend -n app -- curl -m 5 backend
echo -e "\033[35m check access frontend2cache \033[m" 
microk8s kubectl exec deployments/frontend -n app -- curl -m 5 cache
sleep 3

#backend2any
echo -e "\\n \033[35m check access back2frontend \033[m" 
microk8s kubectl exec deployments/backend -n app -- curl -m 5 frontend
echo -e "\\n \033[35m check access back2cache \033[m" 
microk8s kubectl exec deployments/backend -n app -- curl -m 5 cache
sleep 3

#cache2any
echo -e "\\n \033[35m check access cache2frontend \033[m"
microk8s kubectl exec deployments/cache -n app -- curl -m 5 frontend
echo -e "\\n \033[35m check access cache2backend \033[m"
microk8s kubectl exec deployments/cache -n app -- curl -m 5 backend
