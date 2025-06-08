defmodule AtlanticaTodoWeb.TodoLive.Index.SwiftUI do
  use AtlanticaTodoNative, [:render_component, format: :swiftui]
  def render(assigns, _interface) do
    ~LVN"""
    <ZStack style={["background(Color.white)", "ignoresSafeArea()", "preferredColorScheme(.light)"]}>
      <VStack style="fillMaxSize()">
        <Text style={[
          "font(.largeTitle)",
          "fontWeight(.bold)",
          "padding(.top, 32)",
          "padding(.bottom, 12)",
          "frame(maxWidth: .infinity, alignment: .center)"
        ]}>
          My Tasks
        </Text>
        <Divider/>
        <ScrollView style={["spacing(12)", "fillMaxSize()"]}>
          <VStack style={["padding(.horizontal, 16)", "padding(.top, 16)", "padding(.bottom, 16)"]}>
            <%= for todo <- @todos do %>
              <HStack style={[
                "padding()",
                "background(Color.gray.opacity(0.1))",
                "cornerRadius(24)",
              ]}>
                <Toggle isOn={todo.completed} phx-click="toggle" phx-value-id={todo.id}></Toggle>
                <%!-- <Circle style="frame(width: 20, height: 20)"/> --%>
                <VStack class={if todo.completed, do: "completed", else: "incomplete"}>
                  <Text
                    style={["font(.headline)", "foregroundStyle(Color.primary)"]}
                    ><%= todo.title %></Text>
                  <Text style={["font(.subheadline)", "foregroundStyle(.gray)"]} :if={todo.description}><%= todo.description %></Text>
                  <%= if todo.image do %>
                    <Image url={todo.image} style="frame(width: 64, height: 64)"/>
                  <% end %>
                </VStack>
                <Spacer/>
                <.button phx-click="delete" phx-value-id={todo.id}>
                  <.icon name="trash" style="foregroundStyle(.gray)"/>
                </.button>
              </HStack>
            <% end %>
          </VStack>
        </ScrollView>
      </VStack>
      <VStack style="fillMaxSize()">
        <Spacer/>
        <HStack style="padding(.bottom, 16)">
          <Spacer/>
          <ZStack style={[
            "frame(width: 56, height: 56)",
            "background(Color.blue)",
            "cornerRadius(28)",
            "shadow(radius: 4)"
          ]} phx-click="open_form">
            <.icon name="plus" style={[
              "font(.title2)",
              "foregroundStyle(.white)"
            ]}/>
          </ZStack>
        </HStack>
      </VStack>
    </ZStack>
    <.modal show={@show_form} id="todo-form">
      This is a modal.
    </.modal>
    """
  end
end


# ZStack {
#   Color(.systemGray6)
#       .ignoresSafeArea()

#   ScrollView {
#       VStack(spacing: 12) {
#           ForEach(todos) { todo in
#               TodoItemView(todo: todo, onImageTap: { image in
#                   selectedImage = image
#                   showImageDetail = true
#               })
#           }
#       }
#       .padding()
#   }

#   // Floating Action Button
#   VStack {
#       Spacer()
#       HStack {
#           Spacer()
#           Button(action: { showForm = true }) {
#               Image(systemName: "plus")
#                   .font(.title2)
#                   .foregroundColor(.white)
#                   .frame(width: 56, height: 56)
#                   .background(Color.blue)
#                   .clipShape(Circle())
#                   .shadow(radius: 4)
#           }
#           .padding()
#       }
#   }
# }
# .sheet(isPresented: $showForm) {
#   TodoFormView(isPresented: $showForm)
# }
# .sheet(isPresented: $showImageDetail) {
#   if let image = selectedImage {
#       ImageDetailView(image: image, isPresented: $showImageDetail)
#   }
# }
# }
# struct TodoItemView: View {
#   let todo: Todo
#   let onImageTap: (String) -> Void

#   var body: some View {
#       HStack(alignment: .top, spacing: 16) {
#           // Checkbox
#           Circle()
#               .stroke(todo.completed ? Color.green : Color.gray, lineWidth: 2)
#               .frame(width: 20, height: 20)
#               .overlay(
#                   todo.completed ?
#                   Image(systemName: "checkmark")
#                       .font(.system(size: 12))
#                       .foregroundColor(.green)
#                   : nil
#               )

#           VStack(alignment: .leading, spacing: 8) {
#               Text(todo.title)
#                   .font(.headline)
#                   .strikethrough(todo.completed)
#                   .foregroundColor(todo.completed ? .gray : .primary)

#               if let description = todo.description {
#                   Text(description)
#                       .font(.subheadline)
#                       .foregroundColor(.gray)
#               }

#               if let image = todo.image {
#                   AsyncImage(url: URL(string: image)) { image in
#                       image
#                           .resizable()
#                           .aspectRatio(contentMode: .fill)
#                           .frame(width: 64, height: 64)
#                           .clipShape(RoundedRectangle(cornerRadius: 8))
#                           .onTapGesture {
#                               onImageTap(image)
#                           }
#                   } placeholder: {
#                       Color.gray
#                           .frame(width: 64, height: 64)
#                           .clipShape(RoundedRectangle(cornerRadius: 8))
#                   }
#               }
#           }

#           Spacer()

#           Button(action: {}) {
#               Image(systemName: "trash")
#                   .foregroundColor(.gray)
#           }
#       }
#       .padding()
#       .background(Color.white)
#       .cornerRadius(12)
#       .shadow(radius: 2)
#   }
# }

# struct TodoFormView: View {
#   @Binding var isPresented: Bool
#   @State private var title = ""
#   @State private var description = ""

#   var body: some View {
#       NavigationView {
#           Form {
#               Section(header: Text("Task Details")) {
#                   TextField("Title", text: $title)
#                   TextEditor(text: $description)
#                       .frame(height: 100)
#               }

#               Section(header: Text("Image")) {
#                   Button(action: {}) {
#                       HStack {
#                           Image(systemName: "photo")
#                           Text("Add Image")
#                       }
#                   }
#               }
#           }
#           .navigationTitle("New Task")
#           .navigationBarItems(
#               leading: Button("Cancel") {
#                   isPresented = false
#               },
#               trailing: Button("Save") {
#                   isPresented = false
#               }
#           )
#       }
#   }
# }

# struct ImageDetailView: View {
#   let image: String
#   @Binding var isPresented: Bool

#   var body: some View {
#       NavigationView {
#           AsyncImage(url: URL(string: image)) { image in
#               image
#                   .resizable()
#                   .aspectRatio(contentMode: .fit)
#           } placeholder: {
#               ProgressView()
#           }
#           .navigationBarItems(trailing: Button("Close") {
#               isPresented = false
#           })
#       }
#   }
# }

# #Preview {
#   TodoApp()
# }
