defmodule SaucyWeb.PageController do
  use SaucyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
