# Policy Definitions (All scopes) `[Microsoft.Authorization/policyDefinitions]`

This module deploys a Policy Definition at a Management Group or Subscription scope.

## Navigation

- [Resource Types](#Resource-Types)
- [Usage examples](#Usage-examples)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Cross-referenced modules](#Cross-referenced-modules)
- [Notes](#Notes)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Authorization/policyDefinitions` | [2021-06-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2021-06-01/policyDefinitions) |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br:bicep/modules/authorization.policy-definition:1.0.0`.

- [Mg.Common](#example-1-mgcommon)
- [Mg.Min](#example-2-mgmin)
- [Sub.Common](#example-3-subcommon)
- [Sub.Min](#example-4-submin)

### Example 1: _Mg.Common_

<details>

<summary>via Bicep module</summary>

```bicep
module policyDefinition 'br:bicep/modules/authorization.policy-definition:1.0.0' = {
  name: '${uniqueString(deployment().name)}-test-apdmgcom'
  params: {
    // Required parameters
    name: 'apdmgcom001'
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.Resources/subscriptions'
            field: 'type'
          }
          {
            exists: 'false'
            field: '[concat(\'tags[\' parameters(\'tagName\') \']\')]'
          }
        ]
      }
      then: {
        details: {
          operations: [
            {
              field: '[concat(\'tags[\' parameters(\'tagName\') \']\')]'
              operation: 'add'
              value: '[parameters(\'tagValue\')]'
            }
          ]
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f'
          ]
        }
        effect: 'modify'
      }
    }
    // Non-required parameters
    description: '[Description] This policy definition is deployed at the management group scope'
    displayName: '[DisplayName] This policy definition is deployed at the management group scope'
    enableDefaultTelemetry: '<enableDefaultTelemetry>'
    metadata: {
      category: 'Security'
    }
    parameters: {
      tagName: {
        metadata: {
          description: 'Name of the tag such as \'environment\''
          displayName: 'Tag Name'
        }
        type: 'String'
      }
      tagValue: {
        metadata: {
          description: 'Value of the tag such as \'environment\''
          displayName: 'Tag Value'
        }
        type: 'String'
      }
    }
  }
}
```

</details>
<p>

<details>

<summary>via JSON Parameter file</summary>

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    // Required parameters
    "name": {
      "value": "apdmgcom001"
    },
    "policyRule": {
      "value": {
        "if": {
          "allOf": [
            {
              "equals": "Microsoft.Resources/subscriptions",
              "field": "type"
            },
            {
              "exists": "false",
              "field": "[concat(\"tags[\", parameters(\"tagName\"), \"]\")]"
            }
          ]
        },
        "then": {
          "details": {
            "operations": [
              {
                "field": "[concat(\"tags[\", parameters(\"tagName\"), \"]\")]",
                "operation": "add",
                "value": "[parameters(\"tagValue\")]"
              }
            ],
            "roleDefinitionIds": [
              "/providers/microsoft.authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f"
            ]
          },
          "effect": "modify"
        }
      }
    },
    // Non-required parameters
    "description": {
      "value": "[Description] This policy definition is deployed at the management group scope"
    },
    "displayName": {
      "value": "[DisplayName] This policy definition is deployed at the management group scope"
    },
    "enableDefaultTelemetry": {
      "value": "<enableDefaultTelemetry>"
    },
    "metadata": {
      "value": {
        "category": "Security"
      }
    },
    "parameters": {
      "value": {
        "tagName": {
          "metadata": {
            "description": "Name of the tag such as \"environment\"",
            "displayName": "Tag Name"
          },
          "type": "String"
        },
        "tagValue": {
          "metadata": {
            "description": "Value of the tag such as \"environment\"",
            "displayName": "Tag Value"
          },
          "type": "String"
        }
      }
    }
  }
}
```

</details>
<p>

### Example 2: _Mg.Min_

<details>

<summary>via Bicep module</summary>

```bicep
module policyDefinition 'br:bicep/modules/authorization.policy-definition:1.0.0' = {
  name: '${uniqueString(deployment().name)}-test-apdmgmin'
  params: {
    // Required parameters
    name: 'apdmgmin001'
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.KeyVault/vaults'
            field: 'type'
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
      }
    }
    // Non-required parameters
    enableDefaultTelemetry: '<enableDefaultTelemetry>'
    parameters: {
      effect: {
        allowedValues: [
          'Audit'
        ]
        defaultValue: 'Audit'
        type: 'String'
      }
    }
  }
}
```

</details>
<p>

<details>

<summary>via JSON Parameter file</summary>

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    // Required parameters
    "name": {
      "value": "apdmgmin001"
    },
    "policyRule": {
      "value": {
        "if": {
          "allOf": [
            {
              "equals": "Microsoft.KeyVault/vaults",
              "field": "type"
            }
          ]
        },
        "then": {
          "effect": "[parameters(\"effect\")]"
        }
      }
    },
    // Non-required parameters
    "enableDefaultTelemetry": {
      "value": "<enableDefaultTelemetry>"
    },
    "parameters": {
      "value": {
        "effect": {
          "allowedValues": [
            "Audit"
          ],
          "defaultValue": "Audit",
          "type": "String"
        }
      }
    }
  }
}
```

</details>
<p>

### Example 3: _Sub.Common_

<details>

<summary>via Bicep module</summary>

```bicep
module policyDefinition 'br:bicep/modules/authorization.policy-definition:1.0.0' = {
  name: '${uniqueString(deployment().name)}-test-apdsubcom'
  params: {
    // Required parameters
    name: 'apdsubcom001'
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.Resources/subscriptions'
            field: 'type'
          }
          {
            exists: 'false'
            field: '[concat(\'tags[\' parameters(\'tagName\') \']\')]'
          }
        ]
      }
      then: {
        details: {
          operations: [
            {
              field: '[concat(\'tags[\' parameters(\'tagName\') \']\')]'
              operation: 'add'
              value: '[parameters(\'tagValue\')]'
            }
          ]
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f'
          ]
        }
        effect: 'modify'
      }
    }
    // Non-required parameters
    description: '[Description] This policy definition is deployed at subscription scope'
    displayName: '[DisplayName] This policy definition is deployed at subscription scope'
    enableDefaultTelemetry: '<enableDefaultTelemetry>'
    metadata: {
      category: 'Security'
    }
    parameters: {
      tagName: {
        metadata: {
          description: 'Name of the tag such as \'environment\''
          displayName: 'Tag Name'
        }
        type: 'String'
      }
      tagValue: {
        metadata: {
          description: 'Value of the tag such as \'production\''
          displayName: 'Tag Value'
        }
        type: 'String'
      }
    }
  }
}
```

</details>
<p>

<details>

<summary>via JSON Parameter file</summary>

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    // Required parameters
    "name": {
      "value": "apdsubcom001"
    },
    "policyRule": {
      "value": {
        "if": {
          "allOf": [
            {
              "equals": "Microsoft.Resources/subscriptions",
              "field": "type"
            },
            {
              "exists": "false",
              "field": "[concat(\"tags[\", parameters(\"tagName\"), \"]\")]"
            }
          ]
        },
        "then": {
          "details": {
            "operations": [
              {
                "field": "[concat(\"tags[\", parameters(\"tagName\"), \"]\")]",
                "operation": "add",
                "value": "[parameters(\"tagValue\")]"
              }
            ],
            "roleDefinitionIds": [
              "/providers/microsoft.authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f"
            ]
          },
          "effect": "modify"
        }
      }
    },
    // Non-required parameters
    "description": {
      "value": "[Description] This policy definition is deployed at subscription scope"
    },
    "displayName": {
      "value": "[DisplayName] This policy definition is deployed at subscription scope"
    },
    "enableDefaultTelemetry": {
      "value": "<enableDefaultTelemetry>"
    },
    "metadata": {
      "value": {
        "category": "Security"
      }
    },
    "parameters": {
      "value": {
        "tagName": {
          "metadata": {
            "description": "Name of the tag such as \"environment\"",
            "displayName": "Tag Name"
          },
          "type": "String"
        },
        "tagValue": {
          "metadata": {
            "description": "Value of the tag such as \"production\"",
            "displayName": "Tag Value"
          },
          "type": "String"
        }
      }
    }
  }
}
```

</details>
<p>

### Example 4: _Sub.Min_

<details>

<summary>via Bicep module</summary>

```bicep
module policyDefinition 'br:bicep/modules/authorization.policy-definition:1.0.0' = {
  name: '${uniqueString(deployment().name)}-test-apdsubmin'
  params: {
    // Required parameters
    name: 'apdsubmin001'
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.KeyVault/vaults'
            field: 'type'
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
      }
    }
    // Non-required parameters
    enableDefaultTelemetry: '<enableDefaultTelemetry>'
    parameters: {
      effect: {
        allowedValues: [
          'Audit'
        ]
        defaultValue: 'Audit'
        type: 'String'
      }
    }
  }
}
```

</details>
<p>

<details>

<summary>via JSON Parameter file</summary>

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    // Required parameters
    "name": {
      "value": "apdsubmin001"
    },
    "policyRule": {
      "value": {
        "if": {
          "allOf": [
            {
              "equals": "Microsoft.KeyVault/vaults",
              "field": "type"
            }
          ]
        },
        "then": {
          "effect": "[parameters(\"effect\")]"
        }
      }
    },
    // Non-required parameters
    "enableDefaultTelemetry": {
      "value": "<enableDefaultTelemetry>"
    },
    "parameters": {
      "value": {
        "effect": {
          "allowedValues": [
            "Audit"
          ],
          "defaultValue": "Audit",
          "type": "String"
        }
      }
    }
  }
}
```

</details>
<p>


## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-name) | string | Specifies the name of the policy definition. Maximum length is 64 characters for management group scope and subscription scope. |
| [`policyRule`](#parameter-policyrule) | object | The Policy Rule details for the Policy Definition. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`description`](#parameter-description) | string | The policy definition description. |
| [`displayName`](#parameter-displayname) | string | The display name of the policy definition. Maximum length is 128 characters. |
| [`enableDefaultTelemetry`](#parameter-enabledefaulttelemetry) | bool | Enable telemetry via a Globally Unique Identifier (GUID). |
| [`location`](#parameter-location) | string | Location deployment metadata. |
| [`managementGroupId`](#parameter-managementgroupid) | string | The group ID of the Management Group (Scope). If not provided, will use the current scope for deployment. |
| [`metadata`](#parameter-metadata) | object | The policy Definition metadata. Metadata is an open ended object and is typically a collection of key-value pairs. |
| [`mode`](#parameter-mode) | string | The policy definition mode. Default is All, Some examples are All, Indexed, Microsoft.KeyVault.Data. |
| [`parameters`](#parameter-parameters) | object | The policy definition parameters that can be used in policy definition references. |
| [`subscriptionId`](#parameter-subscriptionid) | string | The subscription ID of the subscription (Scope). Cannot be used with managementGroupId. |

### Parameter: `description`

The policy definition description.
- Required: No
- Type: string
- Default: `''`

### Parameter: `displayName`

The display name of the policy definition. Maximum length is 128 characters.
- Required: No
- Type: string
- Default: `''`

### Parameter: `enableDefaultTelemetry`

Enable telemetry via a Globally Unique Identifier (GUID).
- Required: No
- Type: bool
- Default: `True`

### Parameter: `location`

Location deployment metadata.
- Required: No
- Type: string
- Default: `[deployment().location]`

### Parameter: `managementGroupId`

The group ID of the Management Group (Scope). If not provided, will use the current scope for deployment.
- Required: No
- Type: string
- Default: `[managementGroup().name]`

### Parameter: `metadata`

The policy Definition metadata. Metadata is an open ended object and is typically a collection of key-value pairs.
- Required: No
- Type: object
- Default: `{}`

### Parameter: `mode`

The policy definition mode. Default is All, Some examples are All, Indexed, Microsoft.KeyVault.Data.
- Required: No
- Type: string
- Default: `'All'`
- Allowed:
  ```Bicep
  [
    'All'
    'Indexed'
    'Microsoft.ContainerService.Data'
    'Microsoft.KeyVault.Data'
    'Microsoft.Kubernetes.Data'
    'Microsoft.Network.Data'
  ]
  ```

### Parameter: `name`

Specifies the name of the policy definition. Maximum length is 64 characters for management group scope and subscription scope.
- Required: Yes
- Type: string

### Parameter: `parameters`

The policy definition parameters that can be used in policy definition references.
- Required: No
- Type: object
- Default: `{}`

### Parameter: `policyRule`

The Policy Rule details for the Policy Definition.
- Required: Yes
- Type: object

### Parameter: `subscriptionId`

The subscription ID of the subscription (Scope). Cannot be used with managementGroupId.
- Required: No
- Type: string
- Default: `''`


## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `name` | string | Policy Definition Name. |
| `resourceId` | string | Policy Definition resource ID. |
| `roleDefinitionIds` | array | Policy Definition Role Definition IDs. |

## Cross-referenced modules

_None_

## Notes

### Module Usage Guidance

In general, most of the resources under the `Microsoft.Authorization` namespace allows deploying resources at multiple scopes (management groups, subscriptions, resource groups). The `main.bicep` root module is simply an orchestrator module that targets sub-modules for different scopes as seen in the parameter usage section. All sub-modules for this namespace have folders that represent the target scope. For example, if the orchestrator module in the [root](main.bicep) needs to target 'subscription' level scopes. It will look at the relative path ['/subscription/main.bicep'](./subscription/main.bicep) and use this sub-module for the actual deployment, while still passing the same parameters from the root module.

The above method is useful when you want to use a single point to interact with the module but rely on parameter combinations to achieve the target scope. But what if you want to incorporate this module in other modules with lower scopes? This would force you to deploy the module in scope `managementGroup` regardless and further require you to provide its ID with it. If you do not set the scope to management group, this would be the error that you can expect to face:

```bicep
Error BCP134: Scope "subscription" is not valid for this module. Permitted scopes: "managementGroup"
```

The solution is to have the option of directly targeting the sub-module that achieves the required scope. For example, if you have your own Bicep file wanting to create resources at the subscription level, and also use some of the modules from the `Microsoft.Authorization` namespace, then you can directly use the sub-module ['/subscription/main.bicep'](./subscription/main.bicep) as a path within your repository, or reference that same published module from the bicep registry. CARML also published the sub-modules so you would be able to reference it like the following:

**Bicep Registry Reference**
```bicep
module policydefinition 'br:bicepregistry.azurecr.io/bicep/modules/authorization.policy-definition.subscription:version' = {}
```
**Local Path Reference**
```bicep
module policydefinition 'yourpath/module/authorization/policy-definition/subscription/main.bicep' = {}
```

### Parameter Usage: `managementGroupId`

To deploy resource to a Management Group, provide the `managementGroupId` as an input parameter to the module.

<details>

<summary>Parameter JSON format</summary>

```json
"managementGroupId": {
    "value": "contoso-group"
}
```

</details>


<details>

<summary>Bicep format</summary>

```bicep
managementGroupId: 'contoso-group'
```

</details>
<p>

> `managementGroupId` is an optional parameter. If not provided, the deployment will use the management group defined in the current deployment scope (i.e. `managementGroup().name`).

### Parameter Usage: `subscriptionId`

To deploy resource to an Azure Subscription, provide the `subscriptionId` as an input parameter to the module. **Example**:

<details>

<summary>Parameter JSON format</summary>

```json
"subscriptionId": {
    "value": "12345678-b049-471c-95af-123456789012"
}
```

</details>

<details>

<summary>Bicep format</summary>

```bicep
subscriptionId: '12345678-b049-471c-95af-123456789012'
```

</details>
<p>
