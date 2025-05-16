defmodule AtlanticaTodo.Repo do
  use Ecto.Repo,
    otp_app: :atlantica_todo,
    adapter: Ecto.Adapters.SQLite3
end
