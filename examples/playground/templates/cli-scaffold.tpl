// emr containers virtual cluster request
{
    "name": "${emr_name}",
    "containerProvider": {
        "type": "EKS",
        "id": "${eks_name}",
        "info": {
            "eksInfo": {
                "namespace": "default"
            }
        }
    }
}

// fis experiment template
{
    "tags": {
        "Name": "TerminateEKSNodes"
    },
    "description": "Terminate EKS nodes",
    "targets": {
        "eks-nodes": {
            "resourceType": "aws:eks:nodegroup",
            "resourceArns": [
                "${nodegroup}"
            ],
            "selectionMode": "ALL"
        }
    },
    "actions": {
        "TerminateInstances": {
            "actionId": "aws:eks:terminate-nodegroup-instances",
            "description": "terminate the node instances",
            "parameters": {
                "instanceTerminationPercentage": "40"
            },
            "targets": {
                "Nodegroups": "eks-nodes"
            }
        }
    },
    "stopConditions": ${alarm},
    "roleArn": "${role}"
}
