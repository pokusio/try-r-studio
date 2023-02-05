#!/bin/bash

export R_STUDIO_NGINX_VOLUME_DIR="$(pwd)/.run/.nginx"
export R_STUDIO_CERTBOT_VOLUMES_HOME="$(pwd)/.run/.certbot/data/certbot"
# $PWD/.run/.nginx/
# $PWD/.run/.certbot/data/certbot/conf
# $PWD/.run/.certbot/data/certbot/www
echo "# --- "
echo "# --- R_STUDIO_NGINX_VOLUME_DIR=[${R_STUDIO_NGINX_VOLUME_DIR}]"
echo "# --- R_STUDIO_CERTBOT_VOLUMES_HOME=[${R_STUDIO_CERTBOT_VOLUMES_HOME}]"
echo "# --- "


# --- 
# 
# create directory if does not exist
createMountedVolumeDir(){
    export PROVIDED_PATH_ARG=$1
    echo "PROVIDED_PATH_ARG=[${PROVIDED_PATH_ARG}]"
    if [ -d "${PROVIDED_PATH_ARG}" ] 
    then
        echo "Directory [${PROVIDED_PATH_ARG}] exists." 
    else
        echo "Error: Directory [${PROVIDED_PATH_ARG}] does not exists."
        mkdir -p ${PROVIDED_PATH_ARG}
    fi
}


# --- # --- # --- # --- #
# --- # --- # --- 
# --- # --- 
# --- 
# Using (Docker Host)-mounted volumes for users is improper :
#  + This would involve manage disk space dynamically with R-Studio App instances deployments
#  + What we need is using docker volumes using
#    a CSI 'Container Storage Interface'  driver, bound to
#    an easily elastic stoage, e.g. Microsoft Azure Storage Account, AWS S3, eg :
# 
#      -> https://learn.microsoft.com/en-us/azure/aks/azure-files-csi : adapt using this CSI into docker daemon instead of Kubernetes on AKS
#      -> xxx
#      -> xxx
#  
#    That way we can manage disk space usage policy, backup / restore policies, etc... 
# 
# 
# * About Cloud Storages which could be used to manage docker volumes : 
#   * https://cloudinfrastructureservices.co.uk/azure-blob-storage-vs-aws-s3-which-is-better/
# * About Docker volume drivers : 
#   * Azure Storage docker volume drivers : 
#     * https://github.com/Azure/azurefile-dockervolumedriver
#     * https://docs.docker.com/cloud/aci-integration/#using-azure-file-share-as-volumes-in-aci-containers : here they show example how to use [the azure files docker volume driver](https://github.com/Azure/azurefile-dockervolumedriver) in Azure Container Instances (same as AWS ECS Elastic Container Services, Azure probably has the fargate project equivalent for serverless)
#     * this one and only azure driver i found was still recommended even if source code archived, by official docker team https://social.msdn.microsoft.com/Forums/en-US/e7d2b06a-0073-4cbd-aad1-4f3de9ce52c2/how-to-mount-a-volume-in-dockerfile-to-azure-storage-file?forum=windowsazuredata
#     * and i found another blog post fully covering same subject from 2022 (i assume it worked in 2022) : https://medium.com/srcecde/mount-azure-file-storage-as-volume-on-docker-container-in-virtual-m-fc77a9fc5506
# 
createMountedVolumeDir "${R_STUDIO_NGINX_VOLUME_DIR}"
createMountedVolumeDir "${R_STUDIO_CERTBOT_VOLUMES_HOME}/conf"
createMountedVolumeDir "${R_STUDIO_CERTBOT_VOLUMES_HOME}/www"
