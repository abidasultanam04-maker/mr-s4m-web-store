CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    username VARCHAR(30) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user'
        CHECK (role IN ('user', 'admin')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS apps (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    slug VARCHAR(180) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL DEFAULT 'Tools',
    app_type VARCHAR(20) NOT NULL
        CHECK (app_type IN ('web', 'apk')),
    app_url TEXT,
    download_url TEXT,
    icon_url TEXT,
    version VARCHAR(30) NOT NULL DEFAULT '1.0.0',
    is_published BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS downloads (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    app_id BIGINT NOT NULL REFERENCES apps(id) ON DELETE CASCADE,
    downloaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS notifications (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(180) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(30) NOT NULL DEFAULT 'general',
    app_id BIGINT REFERENCES apps(id) ON DELETE SET NULL,
    created_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS notification_reads (
    notification_id BIGINT NOT NULL
        REFERENCES notifications(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL
        REFERENCES users(id) ON DELETE CASCADE,
    read_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (notification_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_apps_published
    ON apps(is_published, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_downloads_user
    ON downloads(user_id, downloaded_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_created
    ON notifications(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_users_last_login
    ON users(last_login DESC);
