defmodule AtlanticaTodoWeb.TodoLive.Index do
  use AtlanticaTodoWeb, :live_view
  alias AtlanticaTodo.Todos.Todo
  alias AtlanticaTodo.Repo
  import Phoenix.HTML.FormData
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:todos, list_todos())
     |> assign(:form, to_form(Todo.changeset(%Todo{}, %{})))
     |> assign(:show_dialog, false)
     |> assign(:image_modal_url, nil)
     |> allow_upload(:image,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1,
       on_upload: fn entry ->
         Logger.info("#### on_upload called for entry: #{inspect(entry)}")
         if entry.done? do
           uploads_dir = Path.join([:code.priv_dir(:atlantica_todo), "static", "uploads"])
           File.mkdir_p!(uploads_dir)
           dest = Path.join(uploads_dir, entry.ref)
           Logger.info("#### copying file to: #{dest}")
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

    {:noreply, assign(socket, :todos, list_todos())}
  end

  @impl true
  def handle_event("toggle", %{"id" => id}, socket) do
    todo = Repo.get!(Todo, id)
    {:ok, _updated_todo} = Repo.update(Ecto.Changeset.change(todo, completed: !todo.completed))

    {:noreply, assign(socket, :todos, list_todos())}
  end

  @impl true
  def handle_event("open_dialog", _, socket) do
    {:noreply,
     socket
     |> assign(:show_dialog, true)}
  end

  @impl true
  def handle_event("close_dialog", _, socket) do
    {:noreply,
     socket
     |> assign(:show_dialog, false)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("upload", _params, socket) do
    Logger.info("#### upload image!! #{inspect(socket.assigns.uploads)}")
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
  def handle_event("open_image_modal", %{"url" => url}, socket) do
    {:noreply, assign(socket, :image_modal_url, url)}
  end

  @impl true
  def handle_event("close_image_modal", _params, socket) do
    {:noreply, assign(socket, :image_modal_url, nil)}
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
      {:ok, _todo} ->
        {:noreply,
         socket
         |> put_flash(:info, "Todo created successfully")
         |> assign(:todos, list_todos())
         |> assign(:form, to_form(Todo.changeset(%Todo{}, %{})))
         |> assign(:show_dialog, false)
         |> push_event("close_dialog", %{})}

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
