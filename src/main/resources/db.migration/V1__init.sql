-- ### Core Entities:
-- **Task:
-- 1)** Title
-- 2) Description
-- 3) Finish date
-- 4) Deadline
-- 5) Frequency date
-- 6) Completion status (Active/Finished)
-- 7) Is subtask flag
-- 8) ID of a parent task (if it is subtask)
--
-- **Task List:**
-- 1) Title
-- 2) Tasks (Finished/Active)
--
-- **User:**
-- 1) Username
-- 2) Email
-- 3) Name
-- 4) Surname
-- 5) Hashed password

CREATE TABLE IF NOT EXISTS users (
     user_id UUID  NOT NULL PRIMARY KEY,
     username VARCHAR(128) NOT NULL UNIQUE,
     first_name VARCHAR(128) NOT NULL,
     last_name VARCHAR(128) NOT NULL,
     phone_number VARCHAR(32),
     email VARCHAR(128) NOT NULL UNIQUE,
     password_hash VARCHAR(256) NOT NULL,
     created_at TIMESTAMPTZ DEFAULT NOW(),
     created_by UUID NOT NULL,
     updated_at TIMESTAMPTZ,
     updated_by UUID
);

CREATE TABLE IF NOT EXISTS tasks (
    task_id UUID  NOT NULL PRIMARY KEY,
    title VARCHAR(128),
    description VARCHAR(256),
    completion_date TIMESTAMPTZ,
    deadline TIMESTAMPTZ,
    is_subtask BOOLEAN DEFAULT FALSE,
    is_completed BOOLEAN DEFAULT FALSE,
    is_overdue BOOL DEFAULT false,
    parent_task_id UUID,

    is_recurring BOOLEAN DEFAULT false NOT NULL,
    -- Базовая частота: 'daily', 'weekly', 'monthly'
    frequency_type VARCHAR(50) CHECK (frequency_type IN ('daily', 'weekly', 'monthly')),
    days_of_week INT[],
    days_of_month INT[],
    next_run_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID NOT NULL,
    updated_at TIMESTAMPTZ,
    updated_by UUID,

    -- Исправлен синтаксис (убрана ; перед CONSTRAINT и исправлена валидация массива)
    CONSTRAINT chk_days_of_week CHECK (days_of_week <@ ARRAY[1,2,3,4,5,6,7]),

    -- БИЗНЕС-ПРАВИЛО: Валидация регулярных и разовых задач
    CONSTRAINT chk_recurring_logic CHECK (
        (is_recurring = FALSE AND frequency_type IS NULL AND days_of_week IS NULL AND days_of_month IS NULL)
        OR
        (is_recurring = TRUE)
    )
);

CREATE TABLE IF NOT EXISTS task_lists (
    task_list_id UUID  NOT NULL PRIMARY KEY,
    task_list_title VARCHAR(128),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID NOT NULL,
    updated_at TIMESTAMPTZ,
    updated_by UUID
);

CREATE TABLE IF NOT EXISTS task_list_tasks (
   task_list_id UUID  NOT NULL,
   task_id UUID  NOT NULL,
   created_at TIMESTAMPTZ DEFAULT NOW(),
   created_by UUID NOT NULL,
   updated_at TIMESTAMPTZ,
   updated_by UUID,
    -- Исправлен синтаксис (добавлены пропущенные запятые перед CONSTRAINT)
    CONSTRAINT fk_task_list_id FOREIGN KEY (task_list_id) REFERENCES task_lists(task_list_id) ON DELETE CASCADE,
    CONSTRAINT fk_task_id FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE,
    PRIMARY KEY (task_list_id, task_id)
);
