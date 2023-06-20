//
//  EnvironmentVarsEditor.swift
//  Harbor
//
//  Created by Venti on 20/06/2023.
//

import SwiftUI

struct EnvironmentVarsEditor: View {
    @Binding var environmentVars: [String: String]
    var body: some View {
        VStack {
            ScrollView {
                HStack(alignment: .bottom) {
                    LazyVStack {
                        ForEach(Array(environmentVars.keys), id: \.self) { key in
                            KVLPairEditor(environmentVars: $environmentVars,
                                          keyValuePair: Binding(
                                            get: { (key, environmentVars[key] ?? "") },
                                            set: { _, _ in }))
                        }
                    }
                    Button {
                        environmentVars["Key_\(environmentVars.count + 1)"] = "Value \(environmentVars.count + 1)"
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .frame(maxHeight: 200)
    }
}

struct EnvironmentVarsEditor_Previews: PreviewProvider {
    @State static var previewVars = ["Key 1": "Value 1",
                                     "Key 2": "Value 2",
                                     "Key 3": "Value 3"]
    static var previews: some View {
        EnvironmentVarsEditor(environmentVars: $previewVars)
            .environment(\.brewUtils, .init())
    }
}

struct KVLPairEditor: View {
    @Binding var environmentVars: [String: String]
    @Binding var keyValuePair: (key: String, value: String)

    @State var tempKey: String = ""

    var body: some View {
        HStack {
            TextField("", text: $tempKey)
            .onSubmit {
                environmentVars.removeValue(forKey: keyValuePair.key)
                environmentVars[tempKey] = keyValuePair.value
            }
            TextField("", text: Binding(
                        get: { keyValuePair.value },
                        set: { newValue in
                            environmentVars[keyValuePair.key] = newValue
                        }))
            Button {
                environmentVars.removeValue(forKey: keyValuePair.key)
            } label: {
                Image(systemName: "minus")
            }
        }
        .onAppear {
            tempKey = keyValuePair.key
        }
    }
}
