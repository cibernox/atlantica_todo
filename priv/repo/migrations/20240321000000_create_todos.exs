defmodule AtlanticaTodo.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :title, :string, null: false
      add :description, :text
      add :completed, :boolean, default: false, null: false

      timestamps()
    end
  end
end
