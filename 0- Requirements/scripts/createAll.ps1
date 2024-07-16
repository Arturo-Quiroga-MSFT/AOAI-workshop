$SubscriptionId = '83d06084-4157-4e25-adfa-4477e0910f91'
$resourceGroupName = "openai-workshop"
$location = "eastus"

# Set subscription 
Set-AzContext -SubscriptionId $subscriptionId 
# Create a resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile deployAll.bicep -WarningAction:SilentlyContinue