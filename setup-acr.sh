RESOURCE_GROUP_NAME=foundation-example
REGISTRY_NAME=foundationrepository
SERVICE_PRINCIPAL_NAME=foundation-access

# Create an Azure Resource Group
az group create --resource-group $RESOURCE_GROUP_NAME --location westeurope

# Create an Azure Container Registry
az acr create --name $REGISTRY_NAME --resource-group $RESOURCE_GROUP_NAME --sku Standard

# Log in the registry
az acr login  --name $REGISTRY_NAME

### Instructions below to create a read-only access to the registry
### (for someone else)

# Get the full ID of the registory
ACR_ID=$(az acr show --name $REGISTRY_NAME --query id --output tsv)

# It will look like this:
# /subscriptions/b638270e-6a3f-4b57-b49b-79291773366f/resourceGroups/foundation-example/providers/Microsoft.ContainerRegistry/registries/foundationrepository

# Create a policy. This command will output the login and password that we need for later.
az ad sp create-for-rbac --name http://$SERVICE_PRINCIPAL_NAME --scopes $ACR_ID --role acrpull 

# The login is the appId, the password is the password field.

# Give the appId and password to your friend.

# Your friend can log in like this.
docker login $REGISTRY_NAME.azurecr.io
