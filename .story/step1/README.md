## First Step : The Docker Compose

Ok, our first step will be to bring up a working docker-compose to run R-Studio in a GNU/Linux Debian machine.

## Design thoughts

### Production-grade requirements

First, to just say things as hey are, this piece of infrastructure is designed for internal use in an AI/Data Science Team : 
* It will be used only by a few well known users (users are people working with you everyday for same company) : for Access Control, we will see but it should not need to be extremely seure, maybe we can have a look at integration of OpenID Connect integration, or Gitlab OAuth2 authentication. 

* Therefore, it will be acessible only from within a private network : For example all human users connect to a VPN network their everyday laptop, and the R-Studio is available from that network.
 
Now, if there are several users, here is what i could think of as a design : 

* In my opionion, every single user, should have its own R-Studio Instance.
* so the users authenticates first, preferably with SSO / OpenID Connect / OAuth2
* Then he has access to his own R-Sudio instance : the only fact that he logs in, launches a new R-Studio Container. _Traefik or its little bro nginx plugin might useful there. We need dynamic reverse proxy listening on docker socket._
* Desired Authentication methods support: Gitlab, Github, microsoft / Azure openid connect (with microsoft email or azure `az login`), google openid, Keycloak OpenID Connect, alibaba iam, aws iam, digital ocean iam.
* As for the storage, we want to be able to easily manage all the storage : 
  * The storage needs to be completely independent from the Virtual machine or the Kubernetes' Cluster Nodes
  * When we are on Kubernetes, we need to use a kubernetes CSI driver, and its `storageClass`
  * As long as we are running on a single Virtual Machine running a docker compose, we need to use a Docker Volume driver, typically from same cloud provider as the VM cloud provider : 
    * in Azure, we will use Azure Account Storage because it is elastic, so we would use https://github.com/Azure/azurefile-dockervolumedriver
    * in AWS we would use S3, or any minio, we would use the official S3 docker volume driver https://docs.docker.com/registry/storage-drivers/s3/
    * one other option : provisinng a second VM with a hude disk space, and only one Minio storage, etc... Well we'd like to save the pain of managing the elasticity of the storage, , but if we haev to, we could, using Minio in a second VM.



#### Networking Architecture Design


Here is an Architecture schema, focusing on the networking aspects of the architecture : 


![R-Studio Architecture - Networking](/.story/step1/img/rstudio-compose.drawio.png)



What you see up there : 
* Devops users are those managing the infrastructure
* The network segmentation is extremely important in terms of security
* We should always use Virtual Machine wit 2 different network interfaces, connected to completely isolated networks: 
  * network (IP address) exposure to "users" (non infra management usage) : a network for using the provisioned services (eg http access to a grafana, or rstudio).
  * network (IP address) exposure to "devops" (infra management usage) : for Devops to `SSH` into VM through `SSH` Bastion (eg executing an ansible playbook, Packer builds using `SSH` connections, all software provisioned to manage infrastruture, like [FluxCD](https://fluxcd.io), [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) [atlantis](https://runatlantis.io), [harbor](https://goharbor.io) using any network protocol like `SSH`, `HTTP`, `UDP`-based protocols, etc...)

_**TODO idea**_

How about we use a CNI driver , Docker networking driver ?

* azure : 
  * https://github.com/Azure/azure-container-networking/blob/master/scripts/install-cni-plugin.sh
  * https://learn.microsoft.com/en-us/azure/virtual-network/deploy-container-networking#download-and-install-the-plug-in
  * https://learn.microsoft.com/en-us/azure/virtual-network/deploy-container-networking#deploy-plug-in-for-docker-containers
  * https://learn.microsoft.com/en-us/azure/virtual-network/container-networking-overview
  * Ok I found full docs and posts on how to do this in Azure : 
    * That is the network driver to use with a docker daemon installed on a single VM, just running docker-compose in the VM : https://github.com/Azure/azure-container-networking
    * That is the post from 2019, giving all details : https://rahul-metangale.medium.com/connecting-docker-container-to-azure-virtual-network-ff8a19913574

<!-- -->

#### Storage Architcture Design

Using (Docker Host)-mounted volumes for users is improper :
* This would involve manage disk space dynamically with R-Studio App instances deployments
* What we need is using docker volumes using a CSI 'Container Storage Interface'  driver, bound to an easily elastic stoage, e.g. Microsoft Azure Storage Account, AWS S3, eg :
  * https://learn.microsoft.com/en-us/azure/aks/azure-files-csi : adapt using this CSI into docker daemon instead of Kubernetes on AKS
  * xxx
  * xxx

That way we can manage disk space usage policy, backup / restore policies, etc... 


* About Cloud Storages which could be used to manage docker volumes : 
  * https://cloudinfrastructureservices.co.uk/azure-blob-storage-vs-aws-s3-which-is-better/
* About Docker volume drivers : 
  * Azure Storage docker volume drivers : 
    * https://github.com/Azure/azurefile-dockervolumedriver
    * https://docs.docker.com/cloud/aci-integration/#using-azure-file-share-as-volumes-in-aci-containers : here they show example how to use [the azure files docker volume driver](https://github.com/Azure/azurefile-dockervolumedriver) in Azure Container Instances (same as AWS ECS Elastic Container Services, Azure probably has the fargate project equivalent for serverless)
    * this one and only azure driver i found was still recommended even if source code archived, by official docker team https://social.msdn.microsoft.com/Forums/en-US/e7d2b06a-0073-4cbd-aad1-4f3de9ce52c2/how-to-mount-a-volume-in-dockerfile-to-azure-storage-file?forum=windowsazuredata
    * and i found another blog post fully covering same subject from 2022 (i assume it worked in 2022) : https://medium.com/srcecde/mount-azure-file-storage-as-volume-on-docker-container-in-virtual-m-fc77a9fc5506



Here is an Architecture schema, focusing on both the networking and storage aspects of the architecture : 


![R-Studio Architecture - Storage](/.story/step1/img/rstudio-infra-storage.drawio.png)


### The Devops CI/CD

The piece of infrastructure we are going to deliver, is a production environment, from the infrastructure management point of view. 


## References

* examples of Docker Compose I found : 
  * https://github.com/TelethonKids/rstudio
  * https://towardsdatascience.com/docker-based-rstudio-postgresql-fbeefe8285bf

* About Reverse Proxies : 
  * Docker Dynamic Reverse Proxy Route Configuration : 
    * nginx: 
      * https://github.com/nginx-proxy/nginx-proxy
      * https://github.com/nginx-proxy/docker-gen
    * traefik: 
      * usual references to find
  * Docker Compose Cert Bot : usual references to find

* About Cloud Storages which could be used to manage docker volumes : 
  * https://cloudinfrastructureservices.co.uk/azure-blob-storage-vs-aws-s3-which-is-better/
* About Docker volume drivers : 
  * Azure Storage docker volume drivers : 
    * https://github.com/Azure/azurefile-dockervolumedriver
    * https://docs.docker.com/cloud/aci-integration/#using-azure-file-share-as-volumes-in-aci-containers : here they show example how to use [the azure files docker volume driver](https://github.com/Azure/azurefile-dockervolumedriver) in Azure Container Instances (same as AWS ECS Elastic Container Services, Azure probably has the fargate project equivalent for serverless)
    * this one and only azure driver i found was still recommended even if source code archived, by official docker team https://social.msdn.microsoft.com/Forums/en-US/e7d2b06a-0073-4cbd-aad1-4f3de9ce52c2/how-to-mount-a-volume-in-dockerfile-to-azure-storage-file?forum=windowsazuredata
    * and i found another blog post fully covering same subject from 2022 (i assume it worked in 2022) : https://medium.com/srcecde/mount-azure-file-storage-as-volume-on-docker-container-in-virtual-m-fc77a9fc5506