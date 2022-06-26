defmodule SaucyWeb.RoomChannel do
  use SaucyWeb, :channel

  @impl true
  def join("room:lobby", _payload, socket) do
    Process.flag(:trap_exit, true)
    {:ok, socket}
  end

  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_in(
        "convert",
        %{"format" => format, "body" => body},
        %{assigns: %{task: task}} = socket
      )
      when format in ["scss", "sass"] and byte_size(body) <= 1_048_576 do
    # cancels an already queued convertion
    kill_task(task)

    # spawning a separate task ensures that the websocket doesnt block
    task = Task.async(SassPool, :compile, [format, body])

    {:noreply, assign(socket, :task, task)}
  end

  @impl true
  def handle_info({ref, converted}, %{assigns: %{task: %Task{ref: ref}}} = socket) do
    # we discard the result if the message is from a previous task
    # it is possible that a task might finish before we cancel it in the handle_in
    # in which case the newer task's ref is different than the received one
    push(socket, "converted", %{"body" => converted})
    {:noreply, assign(socket, :task, nil)}
  end

  @impl true
  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  @impl true
  def terminate(_reason, %{assigns: %{task: task}}) do
    # stops the pool from either connecting the port to another task
    # and it receiving the converted data (this kills the port and restarts it to avoid that)
    # or to stop the task from waiting for a port to be available (this cancels the checkout)
    kill_task(task)
  end

  defp kill_task(%{pid: pid}), do: Process.exit(pid, :kill)
  defp kill_task(_), do: :ok
end
