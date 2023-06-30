defmodule DertGg.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Logger.add_backend(Sentry.LoggerBackend)

    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      {Cluster.Supervisor, [topologies, [name: DertGg.ClusterSupervisor]]},
      # Start the Telemetry supervisor
      DertGgWeb.Telemetry,
      # Start the Ecto repository
      DertGg.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: DertGg.PubSub},
      # Start Finch
      {Finch, name: DertGg.Finch},
      # Start the Endpoint (http/https)
      DertGgWeb.Endpoint
      # Start a worker by calling: DertGg.Worker.start_link(arg)
      # {DertGg.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DertGg.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DertGgWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
