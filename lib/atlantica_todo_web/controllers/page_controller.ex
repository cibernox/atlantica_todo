defmodule AtlanticaTodoWeb.PageController do
  use AtlanticaTodoWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
