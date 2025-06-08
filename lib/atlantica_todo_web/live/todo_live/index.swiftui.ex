defmodule AtlanticaTodoWeb.TodoLive.Index.SwiftUI do
  use AtlanticaTodoNative, [:render_component, format: :swiftui]

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
