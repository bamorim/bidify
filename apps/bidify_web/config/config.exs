# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :bidify_web,
  namespace: Bidify.Web,
  ecto_repos: [Bidify.Web.Repo]

# Configures the endpoint
config :bidify_web, Bidify.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "64+IGyaZMCc4g1s6dtM+gDv2StZHYct/BD7L3ZsXtewdMuqeZeD0udpqpbGZQEzK",
  render_errors: [view: Bidify.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Bidify.Web.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :guardian, Guardian,
  issuer: "Bidify",
  ttl: { 30, :days },
  secret_key: "not_a_secret",
  serializer: Bidify.Web.GuardianSerializer
