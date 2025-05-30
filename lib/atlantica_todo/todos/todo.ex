defmodule AtlanticaTodo.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :title, :string
    field :description, :string
    field :completed, :boolean, default: false
    field :image, :string

    timestamps()
  end

  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :description, :completed, :image])
    |> validate_required([:title])
    |> validate_length(:title, min: 3, max: 75)
    |> validate_length(:description, max: 160)
  end
end
