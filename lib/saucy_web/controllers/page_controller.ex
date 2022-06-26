defmodule SaucyWeb.PageController do
  use SaucyWeb, :controller

  def index(conn, _params) do
    IO.puts("action name is #{action_name(conn)}")

    render(conn, "index.html")
  end
end
