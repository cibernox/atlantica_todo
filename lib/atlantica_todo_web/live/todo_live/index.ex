defmodule AtlanticaTodoWeb.TodoLive.Index do
  use AtlanticaTodoWeb, :live_view
  alias AtlanticaTodo.Todos.Todo
  alias AtlanticaTodo.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, todos: list_todos(), todo: %Todo{})}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Todo List")
    |> assign(:todo, %Todo{})
  end

  @impl true
  def handle_event("save", %{"todo" => todo_params}, socket) do
    save_todo(socket, socket.assigns.live_action, todo_params)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    todo = Repo.get!(Todo, id)
    {:ok, _} = Repo.delete(todo)

    {:noreply, assign(socket, :todos, list_todos())}
  end

  @impl true
  def handle_event("toggle", %{"id" => id}, socket) do
    todo = Repo.get!(Todo, id)
    {:ok, _updated_todo} = Repo.update(Ecto.Changeset.change(todo, completed: !todo.completed))

    {:noreply, assign(socket, :todos, list_todos())}
  end

  defp save_todo(socket, :index, todo_params) do
    case Repo.insert(Todo.changeset(%Todo{}, todo_params)) do
      {:ok, _todo} ->
        {:noreply,
         socket
         |> put_flash(:info, "Todo created successfully")
         |> assign(:todos, list_todos())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp list_todos do
    Repo.all(Todo)
  end
end
