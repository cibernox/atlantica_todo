defmodule AtlanticaTodo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AtlanticaTodoWeb.Telemetry,
      AtlanticaTodo.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:atlantica_todo, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:atlantica_todo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AtlanticaTodo.PubSub},
      # Start a worker by calling: AtlanticaTodo.Worker.start_link(arg)
      # {AtlanticaTodo.Worker, arg},
      # Start to serve requests, typically the last entry
      AtlanticaTodoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AtlanticaTodo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AtlanticaTodoWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") == nil
  end
end
