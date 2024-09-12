defmodule Beabadooble.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BeabadoobleWeb.Telemetry,
      Beabadooble.Repo,
      {Ecto.Migrator,
        repos: Application.fetch_env!(:beabadooble, :ecto_repos)},
      {DNSCluster, query: Application.get_env(:beabadooble, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Beabadooble.PubSub},
      # Start a worker by calling: Beabadooble.Worker.start_link(arg)
      # {Beabadooble.Worker, arg},
      # Start to serve requests, typically the last entry
      BeabadoobleWeb.Endpoint,
      Beabadooble.Songs
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Beabadooble.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BeabadoobleWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  #defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
  #  System.get_env("RELEASE_NAME") != nil
  #end
end
