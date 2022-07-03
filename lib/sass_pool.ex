defmodule Saucy.SassPool do
  require Logger
  @behaviour NimblePool
  @executable Application.app_dir(:saucy, ["priv/sassy/bin/sassy.exe"])

  @impl NimblePool
  def init_worker(_args) do
    Process.flag(:trap_exit, true)

    port =
      Port.open(
        {:spawn_executable, @executable},
        [:binary, :exit_status, :use_stdio, packet: 4]
      )

    {:ok, port, []}
  end

  @impl NimblePool
  def handle_checkout(:checkout, {task_pid, _}, port, pool_state) do
    Port.connect(port, task_pid)
    {:ok, port, port, pool_state}
  end

  @impl NimblePool
  def handle_checkin(:ok, _from, port, pool_state) do
    {:ok, port, pool_state}
  end

  @impl NimblePool
  def handle_checkin(:close, _from, _port, pool_state) do
    {:remove, :closed, pool_state}
  end

  @impl NimblePool
  def handle_info(_message, worker_state) do
    {:ok, worker_state}
  end

  @impl NimblePool
  def terminate_worker(_reason, port, pool_state) do
    Port.close(port)
    {:ok, pool_state}
  end

  def compile(format, data) do
    NimblePool.checkout!(
      __MODULE__,
      :checkout,
      fn {pool_pid, _}, port ->
        Port.command(port, [format, data])

        receive do
          {_port, {:data, processed_data}} ->
            try do
              Port.connect(port, pool_pid)
              {processed_data, :ok}
            rescue
              _error -> {processed_data, :close}
            end
        end
      end,
      :infinity
    )
  end
end
