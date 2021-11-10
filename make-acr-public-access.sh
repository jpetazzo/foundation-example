ACR_ID=$(az acr show --name foundationrepository --query id --output tsv)
az ad sp create-for-rbac --name http://foundation-access --scopes $ACR_ID --role acrpull 
# the login is the appId, the password is the password field
