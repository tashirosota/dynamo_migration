import Config

# use DynamoDB
config :ex_aws,
  access_key_id: "dummy_access_key",
  secret_access_key: "dummy_secret_key",
  region: "us-east-1"

config :ex_aws, :dynamodb,
  scheme: "http://",
  host: "localhost",
  port: "8000",
  region: "us-east-1"
