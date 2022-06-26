defmodule Saucy.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SaucyWeb.Telemetry,
      {NimblePool, worker: {SassPool, []}, name: SassPool, pool_size: 5},
      {Phoenix.PubSub, name: Saucy.PubSub},
      SaucyWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Saucy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SaucyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
