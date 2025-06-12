defmodule AtlanticaTodoWeb.TodoLive.Index do
  use AtlanticaTodoWeb, :live_view
  use AtlanticaTodoNative, :live_view
  alias AtlanticaTodo.Todos.Todo
  alias AtlanticaTodo.Repo
  alias AtlanticaTodo.PubSub
  require Logger
  @topic "todos"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AtlanticaTodo.PubSub, @topic)
    end

    {:ok,
     socket
     |> assign(:todos, list_todos())
     |> assign(:form, to_form(Todo.changeset(%Todo{}, %{})))
     |> assign(:show_form, false)
     |> assign(:image_modal_url, nil)
     |> allow_upload(:image,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1,
       on_upload: fn entry ->
         if entry.done? do
           uploads_dir = Path.join([:code.priv_dir(:atlantica_todo), "static", "uploads"])
           File.mkdir_p!(uploads_dir)
           dest = Path.join(uploads_dir, entry.ref)
           File.cp!(entry.path, dest)
         end
       end
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, assign(socket, :form, new_todo_form())}
  end

  @impl true
  def handle_event("save", %{"todo" => todo_params}, socket) do
    save_todo(socket, socket.assigns.live_action, todo_params)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    todo = Repo.get!(Todo, id)
    {:ok, _} = Repo.delete(todo)
    broadcast({:todo_deleted, id})
    {:noreply, assign(socket, :todos, list_todos())}
  end

  @impl true
  def handle_event("toggle", %{"id" => id}, socket) do
    todo = Repo.get!(Todo, id)
    {:ok, updated_todo} = Repo.update(Ecto.Changeset.change(todo, completed: !todo.completed))

    broadcast({:todo_updated, updated_todo})

    {:noreply, assign(socket, :todos, list_todos())}
  end

  @impl true
  def handle_event("open_form", _, socket) do
    {:noreply, assign(socket, :show_form, true)}
  end

  @impl true
  def handle_event("close_form", _, socket) do
    {:noreply, assign(socket, :show_form, false)}
  end

  @impl true
  def handle_event("preview", %{"ref" => ref}, socket) do
    {:noreply, assign(socket, :preview_ref, ref)}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  @impl true
  def handle_event("open_image_detail", %{"url" => url}, socket) do
    {:noreply, assign(socket, :image_modal_url, url)}
  end

  @impl true
  def handle_event("close_image_detail", _params, socket) do
    {:noreply, assign(socket, :image_modal_url, nil)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:todo_created, _todo}, socket) do
    {:noreply, assign(socket, :todos, list_todos())}
  end

  @impl true
  def handle_info({:todo_updated, _todo}, socket) do
    {:noreply, assign(socket, :todos, list_todos())}
  end

  @impl true
  def handle_info({:todo_deleted, _id}, socket) do
    {:noreply, assign(socket, :todos, list_todos())}
  end

  defp save_todo(socket, :index, todo_params) do
    todo_params
    |> Map.put("image", get_image_path(socket))
    |> Map.update("title", "", &String.trim/1)
    |> Map.update("description", "", &String.trim/1)
    |> then(&Todo.changeset(%Todo{}, &1))
    |> Repo.insert()
    |> case do
      {:ok, todo} ->
        broadcast({:todo_created, todo})

        {:noreply,
          assign(socket, %{todos: list_todos(), form: new_todo_form(), show_form: false})}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp get_image_path(socket) do
    consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
      uploads_dir = Path.join(["priv", "static", "uploads"])
      File.mkdir_p!(uploads_dir)
      extension = Path.extname(entry.client_name)
      filename = "#{entry.uuid}#{extension}"
      dest = Path.join(uploads_dir, filename)
      File.cp!(path, dest)
      {:ok, "/uploads/#{filename}"}
    end)
    |> List.first()
  end

  defp list_todos do
    Repo.all(Todo)
  end

  defp new_todo_form do
    to_form(Todo.changeset(%Todo{title: "", description: ""}, %{}))
  end

  defp broadcast(params) do
    Phoenix.PubSub.broadcast(AtlanticaTodo.PubSub, @topic, params)
  end
end
