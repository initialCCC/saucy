defmodule Saucy.Application do
  use Application
  @workers_count Application.compile_env!(:saucy, :workers_count)

  @impl true
  def start(_type, _args) do
    unless is_integer(@workers_count) and @workers_count > 0 do
      raise "Expected a non neg int for the workers, got #{inspect(@workers_count)}"
    end

    children = [
      SaucyWeb.Telemetry,
      {NimblePool, worker: {Saucy.SassPool, []}, name: Saucy.SassPool, pool_size: @workers_count},
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
