import Config

config :ex_aws,
  debug_requests: true,
  access_key_id: "access_key_id",
  secret_access_key: "secret_access_key",
  region: "us-east-1"

config :ex_aws, :dynamodb,
  scheme: "http://",
  host: "localhost",
  port: 8000,
  region: "us-east-1"
