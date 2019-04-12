#!/bin/bash

set -e

VERSION="$1"
GIT_USER="$2"
GIT_EMAIL="$3"
GIT_TOKEN="$4"
REPO_DIR=/tmp/iofog-platform

if [ "$BRANCH" == "develop" ] || [ "$BRANCH" == "master" ] ; then
    # Checkout the Helm package branch
    git clone -b gh-pages --single-branch https://github.com/eclipse-iofog/iofog-platform.git "$REPO_DIR"
    # Generate Helm packages
    for CHART in iofog iofog-k8s
    do
    	helm package -d "$REPO_DIR" deploy/helm/"$CHART"
    done
    helm repo index "$REPO_DIR" --url https://eclipse-iofog.github.io/iofog-platform/
    # Configure git
    git config user.email "$GIT_EMAIL"
    git config user.name "$GIT_USER"
    # Push new packages
    cd "$REPO_DIR"
    git commit -a -m "$VERSION" 
    git push "https://$GIT_TOKEN@github.com/eclipse-iofog/iofog-platform.git"
else
    echo "Nothing to push in this branch"
fi