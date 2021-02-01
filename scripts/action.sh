#!/bin/bash

set +x
set -e

usage()
{
  echo "Usage: accepts one of the following parameters"
  echo ""
  echo "-p --push"
  echo "-d --deploy"
  echo "-r --rollback"
  echo ""
}


case $1 in
    -p | --push ) 

      docker build -t gcr.io/$PROJECT_ID/$REPO_NAME .

      if [[ -n "$TAG_NAME" ]]; then
        docker tag gcr.io/$PROJECT_ID/$REPO_NAME gcr.io/$PROJECT_ID/$REPO_NAME:$TAG_NAME
        docker push gcr.io/$PROJECT_ID/$REPO_NAME:$TAG_NAME
      elif [[ "$BRANCH_NAME" == "master" ]]; then
        docker push gcr.io/$PROJECT_ID/$REPO_NAME
      else 
        echo "Docker push only occurs on tag or push to master"
      fi
      ;;

    -d | --deploy )

      if [[ -n "$TAG_NAME" ]]; then
        echo "Helm steps skipped on tag trigger"
      else
        helm template ./chart -f "environments/$DEPLOY_TO.yaml"

        COMMIT_MSG=$(git log --oneline)
        if [[ ${COMMIT_MSG:7:13} == " helm-deploy " ]]; then
          DEPLOY_TO=$(echo $COMMIT_MSG | cut -d" " -f3)
          HELM_DEPLOY="TRUE"
        elif [[ "$BASE_BRANCH" == "master" && ${COMMIT_MSG:7:7} == " Merge " ]]; then
          HELM_DEPLOY="TRUE"
        else 
          echo "Helm deploy only occurs on merge to master or commit message matching regex '^helm-deploy .*'"
        fi

        if [[ "$HELM_DEPLOY" == "TRUE" ]]; then
          /builder/helm.bash upgrade $RELEASE_NAME ./chart -f "environments/$DEPLOY_TO.yaml" --install --debug
        fi
      fi
      ;;

    -r | --rollback )

      /builder/helm.bash uninstall $RELEASE_NAME
      ;;

    -h | --help )

      usage
      ;;

    * )                     
    
      usage
      echo "You supplied '$1'"
      exit 1
      ;;
esac
