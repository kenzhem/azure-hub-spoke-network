
---

### 🇷🇺 Russian Version (`README.md` на русском)

```markdown
# Корпоративная сетевая архитектура Hub-and-Spoke в Azure

[![Azure Network CI/CD Security & Deploy](https://github.com/YOUR_USERNAME/azure-hub-spoke-network/actions/workflows/network-deploy.yml/badge.svg)](https://github.com/YOUR_USERNAME/azure-hub-spoke-network/actions/workflows/network-deploy.yml)
[![Terraform Version](https://img.shields.io/badge/Terraform-1.5.0%2B-purple.svg)](https://www.terraform.io/)
[![Cloud Adoption Framework](https://img.shields.io/badge/CAF-Compliant-blue.svg)](https://cloudadoption.microsoft.com/)

Этот репозиторий содержит продакшн-решение корпоративного уровня — **сетевую топологию Hub-and-Spoke** в Microsoft Azure, развернутую с помощью **Terraform** и полностью автоматизированную через **GitHub Actions CI/CD**. Архитектура строго соответствует рекомендациям **Microsoft Cloud Adoption Framework (CAF)** и принципам безопасности Zero Trust.

---

## 🏗️ Обзор архитектуры

- **Хаб (Hub VNet - `10.0.0.0/16`)**:
  - `AzureFirewallSubnet`: Централизованный Azure Firewall для инспекции трафика.
  - `AzureBastionSubnet`: Подсеть для безопасного администрирования.
- **Спица (Spoke Prod VNet - `10.1.0.0/16`)**:
  - `AppSubnet` и `DBSubnet`: Изолированные уровни приложения и базы данных.
- **Маршрутизация**:
  - **User Defined Routes (UDR)**: Весь исходящий и межуровневый трафик спиц (`0.0.0.0/0`) принудительно направляется через центральный файрвол.
  - **VNet Peering**: Двунаправленный пиринг с поддержкой пересылки транзитного трафика.

---

## 📁 Структура репозитория

```text
.
├── .github/
│   └── workflows/
│       └── network-deploy.yml       # CI/CD пайплайн (Линтинг, Checkov, Apply)
└── terraform/
    ├── modules/
    │   ├── vnet/                    # Переиспользуемый модуль VNet и подсетей
    │   └── firewall/                # Модуль Azure Firewall и маршрутизации
    └── environments/
        └── dev/
            ├── main.tf              # Основной файл конфигурации и бэкенд
            ├── variables.tf
            └── outputs.tf


🚀 CI/CD Пайплайн и безопасность
Пайплайн GitHub Actions проверяет код при каждом коммите:

TFLint: Статический анализ кода Terraform.
Checkov: Сканирование безопасности IaC на соответствие стандартам.
OIDC Аутентификация: Беспарольный доступ к Azure по временным токенам.
Контроль деплоя: terraform plan на Pull Request, автоматический terraform apply при слиянии в main.