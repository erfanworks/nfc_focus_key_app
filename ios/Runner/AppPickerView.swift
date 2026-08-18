import SwiftUI
import FamilyControls

struct AppPickerView: View {
    @State private var selection: FamilyActivitySelection
    let onDone: (FamilyActivitySelection) -> Void

    init(selection: FamilyActivitySelection, onDone: @escaping (FamilyActivitySelection) -> Void) {
        _selection = State(initialValue: selection)
        self.onDone = onDone
    }

    var body: some View {
        NavigationView {
            FamilyActivityPicker(selection: $selection)
                .navigationTitle("Select Apps to Lock")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { onDone(selection) }
                    }
                }
        }
    }
}
