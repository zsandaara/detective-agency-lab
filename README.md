# Лаба 1. Модель данных и схема

Тема: Детективное агентство.

## ER-диаграмма

```mermaid
erDiagram
    CLIENTS {
        int id PK
        text name
        text email UK
        text phone
        text address
    }
    DETECTIVES {
        int id PK
        text name
        text email UK
        text phone
        text rank
        date hire_date
    }
    CASES {
        int id PK
        int client_id FK
        text title
        text description
        text status
        timestamptz opened_at
        timestamptz closed_at
        numeric fee
    }
    CASE_DETECTIVES {
        int case_id PK, FK
        int detective_id PK, FK
        text role
        timestamptz assigned_at
    }
    EVIDENCE {
        int id PK
        int case_id FK
        text description
        timestamptz found_at
        text type
    }
    SUSPECTS {
        int id PK
        int case_id FK
        text name
        text alias
        text status
    }
    REPORTS {
        int id PK
        int case_id FK
        int detective_id FK
        timestamptz created_at
        text content
        numeric hours_spent
    }

    CLIENTS ||--o{ CASES : "has"
    DETECTIVES ||--o{ CASE_DETECTIVES : "assigned"
    CASES ||--o{ CASE_DETECTIVES : "includes"
    CASES ||--o{ EVIDENCE : "has"
    CASES ||--o{ SUSPECTS : "has"
    CASES ||--o{ REPORTS : "has"
    DETECTIVES ||--o{ REPORTS : "writes"