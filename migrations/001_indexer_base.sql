-- fdw extension for remote link
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- link sarafu_network db
CREATE SCHEMA IF NOT EXISTS sarafu_network;
CREATE SERVER IF NOT EXISTS sarafu_network_remote FOREIGN DATA WRAPPER postgres_fdw OPTIONS
    (host '{{env "REMOTE_DB_HOST" }}', port '{{env "REMOTE_DB_PORT" }}', dbname '{{env "REMOTE_DB_NAME" }}');
CREATE USER MAPPING IF NOT EXISTS FOR postgres SERVER sarafu_network_remote OPTIONS
    (user '{{env "REMOTE_DB_USER" }}', password  '{{env "REMOTE_DB_PASSWORD" }}');
IMPORT FOREIGN SCHEMA public LIMIT TO (accounts) FROM SERVER sarafu_network_remote INTO sarafu_network;

--
CREATE TABLE IF NOT EXISTS tx (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tx_hash VARCHAR(66) NOT NULL UNIQUE,
  block_number INT NOT NULL,
  contract_address VARCHAR(42) NOT NULL,
  date_block TIMESTAMP NOT NULL,
  success BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS token_transfer (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tx_id INT REFERENCES tx(id),
  sender_address VARCHAR(42) NOT NULL,
  recipient_address VARCHAR(42) NOT NULL,
  transfer_value NUMERIC NOT NULL
);

CREATE TABLE IF NOT EXISTS token_mint (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tx_id INT REFERENCES tx(id),
  minter_address VARCHAR(42) NOT NULL,
  recipient_address VARCHAR(42) NOT NULL,
  mint_value NUMERIC NOT NULL
);

CREATE TABLE IF NOT EXISTS token_burn (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tx_id INT REFERENCES tx(id),
  burner_address VARCHAR(42) NOT NULL,
  burn_value NUMERIC NOT NULL
);

CREATE TABLE IF NOT EXISTS faucet_give (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tx_id INT REFERENCES tx(id),
  token_address VARCHAR(42) NOT NULL,
  recipient_address VARCHAR(42) NOT NULL,
  give_value NUMERIC NOT NULL

);

CREATE TABLE IF NOT EXISTS pool_swap (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tx_id INT REFERENCES tx(id),
  initiator_address VARCHAR(42) NOT NULL,
  token_in_address VARCHAR(42) NOT NULL,
  token_out_address VARCHAR(42) NOT NULL,
  in_value NUMERIC NOT NULL,
  out_value NUMERIC NOT NULL,
  fee NUMERIC NOT NULL
);

CREATE TABLE IF NOT EXISTS pool_deposit (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tx_id INT REFERENCES tx(id),
  initiator_address VARCHAR(42) NOT NULL,
  token_in_address VARCHAR(42) NOT NULL,
  in_value NUMERIC NOT NULL
);

CREATE TABLE IF NOT EXISTS price_index_updates (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tx_id INT REFERENCES tx(id),
  token VARCHAR(42) NOT NULL,
  exchange_rate NUMERIC NOT NULL
);


CREATE TABLE IF NOT EXISTS contracts (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  contract_address VARCHAR(42) UNIQUE NOT NULL,
  contract_description TEXT NOT NULL,
  is_token BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS tokens (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  contract_address VARCHAR(42) UNIQUE NOT NULL,
  token_name TEXT NOT NULL,
  token_symbol TEXT NOT NULL,
  token_decimals INT NOT NULL,
  token_version TEXT NOT NULL,
  token_type TEXT NOT NULL
);