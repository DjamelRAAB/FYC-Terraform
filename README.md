# FYC-Terraform
Déploiement d'un cluster AKS et registery Docker sur Azure avec Terraformm

### ModeOp : 
* Renseigner les information d’authentification dans le fichier terraform.tfvars.
* Changer l'image à inclure dans le registry docker dans le main.tf (par défaut nginx)

### Remarque: 
Si vous exécutez votre plan Terraform à l'aide d'un principal de service, assurez-vous qu'il dispose des autorisations nécessaires pour lire les applications à partir d'Azure AD.
[Consulter la documentation](https://docs.microsoft.com/fr-fr/azure/role-based-access-control/role-assignments-portal) si vous voulez en savoir plus sur la façon d'accorder les autorisations nécessaires au principal de service.
