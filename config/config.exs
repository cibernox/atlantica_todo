# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :atlantica_todo,
  ecto_repos: [AtlanticaTodo.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :atlantica_todo, AtlanticaTodoWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: AtlanticaTodoWeb.ErrorHTML, json: AtlanticaTodoWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: AtlanticaTodo.PubSub,
  live_view: [signing_salt: "dT8doGcL"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :atlantica_todo, AtlanticaTodo.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  atlantica_todo: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.0.9",
  atlantica_todo: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix_template, :format_encoders, [
  swiftui: Phoenix.HTML.Engine
]

config :mime, :types, %{
  "text/styles" => ["styles"],
  "text/swiftui" => ["swiftui"]
}

config :live_view_native, plugins: [
  LiveViewNative.SwiftUI
]

config :phoenix, :template_engines, [
  neex: LiveViewNative.Template.Engine
]

config :live_view_native_stylesheet,
  content: [
    swiftui: [
      "lib/**/swiftui/*",
      "lib/**/*swiftui*"
    ]
  ],
  output: "priv/static/assets"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
