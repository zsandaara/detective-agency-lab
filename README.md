# Лаба 1. Модель данных и схема

Тема: Детективное агентство.
Студент: Захарова Сандаара  
Группа: Б9124-09.03.03git add .  
Дата сдачи: 2026-10-16

## О базе данных

Назначение: База данных предназначена для учёта работы частного детективного агентства: клиентов, детективов, дел, улик, подозреваемых и отчётов. Она позволяет вести дела от момента обращения клиента до закрытия, фиксировать, какие детективы работают над каким делом, какие улики и подозреваемые относятся к делу, и сколько часов каждый детектив потратил на отчёты.

Зачем нужна: Без единой базы информация о делах хранилась бы в разрозненных таблицах Excel и бумажных журналах: данные клиентов дублировались бы в каждом деле, было бы невозможно быстро понять, кто из детективов занят на каких делах, а улики и подозреваемые терялись бы между файлами. База решает эти проблемы за счёт нормализации, ограничений целостности и связей между таблицами.

### Описание таблиц

clients — клиенты агентства, то есть физические и юридические лица, которые обратились за услугами. Здесь хранятся имя, email (уникальный), телефон и адрес. Первичный ключ — id.

detectives — сотрудники агентства: детективы и консультанты. Хранятся имя, email (уникальный), телефон, должность (rank) и дата приёма на работу. Должность ограничена значениями junior, senior, lead, consultant. Первичный ключ — id.

cases — дела, открытые по обращениям клиентов. У каждого дела есть ссылка на клиента (client_id), название, описание, статус (open, closed, suspended), дата открытия, дата закрытия (может быть пустой, пока дело не закрыто) и гонорар (fee). Первичный ключ — id.

case_detectives — связующая таблица между делами и детективами. Она реализует связь «многие ко многим»: один детектив может работать над несколькими делами, а над одним делом — несколько детективов. У таблицы составной первичный ключ (case_id, detective_id), и оба этих поля являются внешними ключами. Дополнительно хранится роль детектива в деле (lead, member, consultant) и дата назначения.

evidence — улики, собранные по каждому делу. Хранится описание улики, дата и время обнаружения и тип: physical, digital, testimony, document. Есть ссылка на дело (case_id). Первичный ключ — id.

suspects — подозреваемые и лица, представляющие интерес, по каждому делу. Хранится имя, возможный псевдоним и статус: person_of_interest, suspect, cleared, arrested. Есть ссылка на дело (case_id). Первичный ключ — id.

reports — отчёты детективов по делам. У каждого отчёта есть ссылка на дело (case_id), ссылка на детектива (detective_id), дата создания, текст и количество затраченных часов. Первичный ключ — id.

### Связи между таблицами

Связь один ко многим встречается несколько раз: у одного клиента может быть много дел (clients → cases), у одного дела — много улик, подозреваемых и отчётов (cases → evidence, cases → suspects, cases → reports), а один детектив может написать много отчётов (detectives → reports).

Связь многие ко многим одна: между делами и детективами. Она реализована через связующую таблицу case_detectives.

### Целостность и ограничения

У каждой таблицы есть первичный ключ id типа SERIAL PRIMARY KEY. Внешние ключи не дают ссылаться на несуществующие строки в других таблицах. Поля name, email, title, fee и другие обязательные помечены NOT NULL. Уникальность обеспечивают UNIQUE на clients.email и detectives.email, а также составной первичный ключ case_detectives (case_id, detective_id). Ограничения CHECK проверяют корректность значений: fee >= 0, status IN (...), hours_spent > 0, closed_at > opened_at. Деньги хранятся в numeric(10,2), время — в timestamptz, чтобы учитывать часовой пояс.

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