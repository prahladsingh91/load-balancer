resource "azurerm_public_ip" "public" {
  name                = "lbpublic"
  location            = "westeurope"

  resource_group_name = "lbrg"
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "testlbn" {
  name                = "TestLoadBalancer"
  location            = "westeurope"
  resource_group_name = "lbrg"
  sku                 = "Standard"
#   sku_tier            = "Regional"
  

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.public.id
  }
}
resource "azurerm_lb_backend_address_pool" "backendpool" {
  loadbalancer_id = azurerm_lb.testlbn.id
  name            = "BackEndAddressPool"
}

data "azurerm_network_interface" "datanic1" {
  name                = "vm01753_z1"
  resource_group_name = "lbrg"
}
resource "azurerm_network_interface_backend_address_pool_association" "nicback1" {
  network_interface_id    = data.azurerm_network_interface.datanic1.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backendpool.id
}
data "azurerm_network_interface" "datanic3" {
  name                = "vm02494_z1"
  resource_group_name = "lbrg"
}
resource "azurerm_network_interface_backend_address_pool_association" "nicback3" {
  network_interface_id    = data.azurerm_network_interface.datanic3.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backendpool.id
}
resource "azurerm_lb_probe" "healthprobe" {
  loadbalancer_id = azurerm_lb.testlbn.id
  name            = "healthprobe"
  port            = 22
}
resource "azurerm_lb_rule" "lbnrule" {
  loadbalancer_id                = azurerm_lb.testlbn.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.healthprobe.id
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.backendpool.id]
}


