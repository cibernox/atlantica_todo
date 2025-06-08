defmodule AtlanticaTodoWeb.TodoLive.Index do
  use AtlanticaTodoWeb, :live_view
  use AtlanticaTodoNative, :live_view
  alias AtlanticaTodo.Todos.Todo
  alias AtlanticaTodo.Repo

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
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Todo List")
    |> assign(:form, to_form(Todo.changeset(%Todo{}, %{})))
  end

  @impl true
  def handle_event("save", %{"todo" => todo_params}, socket) do
    save_todo(socket, socket.assigns.live_action, todo_params)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    todo = Repo.get!(Todo, id)
    {:ok, _} = Repo.delete(todo)

    Phoenix.PubSub.broadcast(
      AtlanticaTodo.PubSub,
      @topic,
      {:todo_deleted, id}
    )

    {:noreply, assign(socket, :todos, list_todos())}
  end

  @impl true
  def handle_event("toggle", %{"id" => id}, socket) do
    todo = Repo.get!(Todo, id)
    {:ok, updated_todo} = Repo.update(Ecto.Changeset.change(todo, completed: !todo.completed))

    Phoenix.PubSub.broadcast(
      AtlanticaTodo.PubSub,
      @topic,
      {:todo_updated, updated_todo}
    )

    {:noreply, assign(socket, :todos, list_todos())}
  end

  @impl true
  def handle_event("open_form", _, socket) do
    {:noreply,
     socket
     |> assign(:show_form, true)}
  end

  @impl true
  def handle_event("close_form", _, socket) do
    {:noreply,
     socket
     |> assign(:show_form, false)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("upload", _params, socket) do
    {:noreply, socket}
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
  def handle_event("noop", _, socket), do: {:noreply, socket}

  @impl true
  def handle_info({:todo_created, todo}, socket) do
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
    image_path =
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

    todo_params = Map.put(todo_params, "image", image_path)

    case Repo.insert(Todo.changeset(%Todo{}, todo_params)) do
      {:ok, todo} ->
        Phoenix.PubSub.broadcast(
          AtlanticaTodo.PubSub,
          @topic,
          {:todo_created, todo}
        )

        {:noreply,
         socket
         |> put_flash(:info, "Todo created successfully")
         |> assign(:todos, list_todos())
         |> assign(:form, to_form(Todo.changeset(%Todo{}, %{})))
         |> assign(:show_form, false)
         |> push_event("close_form", %{})}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset))}
    end
  end

  defp list_todos do
    Repo.all(Todo)
  end
end
