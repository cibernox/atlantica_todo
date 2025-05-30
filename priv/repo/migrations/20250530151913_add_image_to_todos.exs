defmodule AtlanticaTodo.Repo.Migrations.AddImageToTodos do
  use Ecto.Migration

  def change do
    alter table(:todos) do
      add :image, :string
    end
  end
end
