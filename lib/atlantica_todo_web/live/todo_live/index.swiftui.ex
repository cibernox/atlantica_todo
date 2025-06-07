defmodule AtlanticaTodoWeb.TodoLive.Index.SwiftUI do
  use AtlanticaTodoNative, [:render_component, format: :swiftui]
  def render(assigns, _interface) do
    ~LVN"""
    <Text>My Tasks</Text>
    <ZStack>
      <ScrollView>
        <VStack>
          <HStack>
            <Circle class="frame(width:20,height:20)"/>
            <Text>Task 1</Text>
          </HStack>
          <HStack>
            <Circle class="frame(width:20,height:20)"/>
            <Text>Task 2</Text>
          </HStack>
          <HStack>
            <Circle class="frame(width:20,height:20)"/>
            <Text>Task 3</Text>
          </HStack>
        </VStack>
      </ScrollView>
    </ZStack>
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
