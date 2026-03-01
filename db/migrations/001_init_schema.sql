-- =============================================================================
-- Charity Chain — PostgreSQL Schema
-- Migration: 001_init_schema.sql
-- =============================================================================

-- ─── ENUM TYPES ──────────────────────────────────────────────────────────────

CREATE TYPE campaign_status AS ENUM ('active', 'completed', 'cancelled');
CREATE TYPE withdrawal_status AS ENUM ('voting', 'approved', 'rejected');
CREATE TYPE transaction_type AS ENUM ('donation', 'disbursement');

-- ─── USERS ───────────────────────────────────────────────────────────────────
-- role: 0=Admin  1=Guest  2=CharityOrg  3=Voter
-- wallet_address: nullable (only connected users have it, format: 0x + 40 hex)

CREATE TABLE users (
    id             SERIAL PRIMARY KEY,
    email          VARCHAR(255)        NOT NULL UNIQUE,
    password       VARCHAR(255)        NOT NULL,
    full_name      VARCHAR(255)        NOT NULL DEFAULT '',
    role           SMALLINT            NOT NULL DEFAULT 1,
    wallet_address VARCHAR(42)         UNIQUE,
    created_at     TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    deleted_at     TIMESTAMPTZ
);

CREATE INDEX idx_users_role       ON users(role);
CREATE INDEX idx_users_deleted_at ON users(deleted_at);

-- ─── CAMPAIGNS ───────────────────────────────────────────────────────────────
-- goal_amount / current_amount: NUMERIC(36,18) to support ERC-20 token decimals
-- token_address   : ERC-20 contract address (e.g. USDT on Sepolia)
-- contract_address: smart contract managing this campaign's vault

CREATE TABLE campaigns (
    id               SERIAL PRIMARY KEY,
    title            VARCHAR(255)        NOT NULL,
    description      TEXT,
    image_url        TEXT,
    goal_amount      NUMERIC(36, 18)     NOT NULL CHECK (goal_amount > 0),
    current_amount   NUMERIC(36, 18)     NOT NULL DEFAULT 0,
    token_address    VARCHAR(42)         NOT NULL,
    contract_address VARCHAR(42),
    charity_id       INTEGER             NOT NULL REFERENCES users(id),
    status           campaign_status     NOT NULL DEFAULT 'active',
    deadline         TIMESTAMPTZ,
    created_at       TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    deleted_at       TIMESTAMPTZ
);

CREATE INDEX idx_campaigns_charity_id  ON campaigns(charity_id);
CREATE INDEX idx_campaigns_status      ON campaigns(status);
CREATE INDEX idx_campaigns_deleted_at  ON campaigns(deleted_at);

-- ─── WITHDRAWAL REQUESTS ─────────────────────────────────────────────────────
-- yes_votes / no_votes: denormalized counters for fast read (updated on each vote)
-- tx_hash            : filled in after on-chain disbursement (APPROVED only)

CREATE TABLE withdrawal_requests (
    id             SERIAL PRIMARY KEY,
    campaign_id    INTEGER             NOT NULL REFERENCES campaigns(id),
    charity_id     INTEGER             NOT NULL REFERENCES users(id),
    amount         NUMERIC(36, 18)     NOT NULL CHECK (amount > 0),
    reason         TEXT                NOT NULL,
    proof_url      TEXT,
    status         withdrawal_status   NOT NULL DEFAULT 'voting',
    voting_deadline TIMESTAMPTZ        NOT NULL,
    yes_votes      INTEGER             NOT NULL DEFAULT 0,
    no_votes       INTEGER             NOT NULL DEFAULT 0,
    tx_hash        VARCHAR(66),
    created_at     TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    deleted_at     TIMESTAMPTZ
);

CREATE INDEX idx_wr_campaign_id  ON withdrawal_requests(campaign_id);
CREATE INDEX idx_wr_charity_id   ON withdrawal_requests(charity_id);
CREATE INDEX idx_wr_status       ON withdrawal_requests(status);
CREATE INDEX idx_wr_deleted_at   ON withdrawal_requests(deleted_at);

-- ─── VOTES ───────────────────────────────────────────────────────────────────
-- UNIQUE(request_id, voter_id) enforces: 1 wallet = 1 vote per request
-- No soft delete — votes are immutable once cast

CREATE TABLE votes (
    id          SERIAL PRIMARY KEY,
    request_id  INTEGER     NOT NULL REFERENCES withdrawal_requests(id),
    voter_id    INTEGER     NOT NULL REFERENCES users(id),
    is_approved BOOLEAN     NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_vote_per_request UNIQUE (request_id, voter_id)
);

CREATE INDEX idx_votes_request_id ON votes(request_id);
CREATE INDEX idx_votes_voter_id   ON votes(voter_id);

-- ─── TRANSACTIONS ────────────────────────────────────────────────────────────
-- Immutable on-chain record; no soft delete
-- request_id: NULL for donation type, filled for disbursement type

CREATE TABLE transactions (
    id           SERIAL PRIMARY KEY,
    campaign_id  INTEGER             NOT NULL REFERENCES campaigns(id),
    request_id   INTEGER             REFERENCES withdrawal_requests(id),
    tx_hash      VARCHAR(66)         NOT NULL UNIQUE,
    amount       NUMERIC(36, 18)     NOT NULL,
    from_address VARCHAR(42)         NOT NULL,
    to_address   VARCHAR(42)         NOT NULL,
    type         transaction_type    NOT NULL,
    created_at   TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_transactions_campaign_id ON transactions(campaign_id);
CREATE INDEX idx_transactions_request_id  ON transactions(request_id);
CREATE INDEX idx_transactions_type        ON transactions(type);

-- ─── AUTO-UPDATE updated_at TRIGGER ─────────────────────────────────────────

CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at_users
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

CREATE TRIGGER set_updated_at_campaigns
    BEFORE UPDATE ON campaigns
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

CREATE TRIGGER set_updated_at_withdrawal_requests
    BEFORE UPDATE ON withdrawal_requests
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
