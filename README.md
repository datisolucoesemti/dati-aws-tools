# DATI ACC TOOLS

Este repositório contém scripts úteis ao onboard de uma nova
conta de cliente DATI.

## Lista de scripts:

### shared_functions.sh

Funções compartilhadas entre todos os scripts.
Não é necessário utilizar este arquivo diretamente.

### create_cost_report.sh

Cria os seguintes recursos:
* S3 bucket `${ACCOUNT_ID}-dati-cost-report`
* AWS Cost Report `DatiCostReport`

O report será criado no path `/cost-report` e um sumário com os
dados será impresso ao final da execução.

Usage:

```
bash create_cost_report.sh
```

### set_password_policy.sh

Configura as políticas padrões de senha na conta AWS incluindo:
* Tamanho mínimo de senha de 10 caracteres
* Exigência de pelo menos 1 simbolo
* Exigência de pelo menos 1 numero
* Exigência de pelo menos 1 letra maiúscula
* Senha expira em 90 dias
* As últimas 5 senhas não podem ser reutilizadas
* Permite que usuários alterem suas próprias senhas

Usage:
```
bash set_password_policy.sh
```
