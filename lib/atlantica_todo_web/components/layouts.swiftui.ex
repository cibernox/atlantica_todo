defmodule AtlanticaTodoWeb.Layouts.SwiftUI do
  use AtlanticaTodoNative, [:layout, format: :swiftui]

  embed_templates "layouts_swiftui/*"
end
