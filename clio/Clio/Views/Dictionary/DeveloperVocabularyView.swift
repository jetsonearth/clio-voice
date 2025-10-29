import SwiftUI

struct DeveloperVocabularyView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Developer vocabulary data organized by category
    private let vocabularyCategories: [(String, String, [(String, String)])] = [
        ("Git Commands", "terminal.fill", [
            ("get add", "git add"),
            ("get commit", "git commit"),
            ("get push", "git push"),
            ("get pull", "git pull"),
            ("get clone", "git clone"),
            ("get checkout", "git checkout"),
            ("get merge", "git merge"),
            ("get rebase", "git rebase"),
            ("get status", "git status"),
            ("get log", "git log"),
            ("get diff", "git diff"),
            ("get branch", "git branch"),
            ("get fetch", "git fetch"),
            ("get reset", "git reset"),
            ("get stash", "git stash")
        ]),
        ("Technical Acronyms", "doc.text.fill", [
            ("jason", "JSON"),
            ("j son", "JSON"),
            ("a p i", "API"),
            ("c l i", "CLI"),
            ("sequel", "SQL"),
            ("s q l", "SQL"),
            ("u r l", "URL"),
            ("h t m l", "HTML"),
            ("c s s", "CSS"),
            ("u i", "UI"),
            ("u x", "UX")
        ]),
        ("React & JavaScript", "swift", [
            ("use state", "useState"),
            ("use effect", "useEffect"),
            ("use context", "useContext"),
            ("use memo", "useMemo"),
            ("use callback", "useCallback"),
            ("use ref", "useRef"),
            ("java script", "JavaScript"),
            ("type script", "TypeScript"),
            ("node j s", "Node.js"),
            ("react j s", "React.js"),
            ("view j s", "Vue.js")
        ]),
        ("SwiftUI & iOS", "apple.logo", [
            ("v stack", "VStack"),
            ("h stack", "HStack"),
            ("z stack", "ZStack"),
            ("lazy v grid", "LazyVGrid"),
            ("at state", "@State"),
            ("at binding", "@Binding"),
            ("at published", "@Published"),
            ("at observed object", "@ObservedObject"),
            ("swift u i", "SwiftUI"),
            ("u i kit", "UIKit"),
            ("x code", "Xcode")
        ]),
        ("Programming Languages", "chevron.left.forwardslash.chevron.right", [
            ("python", "Python"),
            ("java", "Java"),
            ("c plus plus", "C++"),
            ("c sharp", "C#"),
            ("go lang", "Go"),
            ("rust", "Rust"),
            ("kotlin", "Kotlin"),
            ("swift", "Swift"),
            ("ruby", "Ruby"),
            ("p h p", "PHP"),
            ("dart", "Dart"),
            ("flutter", "Flutter")
        ]),
        ("Cloud & DevOps", "cloud.fill", [
            ("docker", "Docker"),
            ("kubernetes", "Kubernetes"),
            ("a w s", "AWS"),
            ("google cloud", "Google Cloud"),
            ("microsoft azure", "Microsoft Azure"),
            ("github", "GitHub"),
            ("git lab", "GitLab"),
            ("bit bucket", "Bitbucket")
        ])
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.borderless)
                .keyboardShortcut(.escape, modifiers: [])
                
                Spacer()
                
                Text("Built-in Developer Vocabulary")
                    .font(.headline)
                
                Spacer()
                
                // Placeholder for symmetry
                Text("Close")
                    .opacity(0)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.windowBackgroundColor).opacity(0.4))
            
            Divider()
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Header description
                    VStack(spacing: 8) {
                        Text("200+ Built-in Corrections")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Automatically fixes common ASR failures that affect developers daily. These corrections are applied when Developer Vocabulary is enabled.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 500)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)
                    
                    // Categories
                    ForEach(vocabularyCategories.indices, id: \.self) { index in
                        let (title, iconName, corrections) = vocabularyCategories[index]
                        
                        VStack(alignment: .leading, spacing: 12) {
                            // Category header
                            HStack {
                                Image(systemName: iconName)
                                    .foregroundColor(.blue)
                                    .font(.system(size: 16))
                                
                                Text(title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("\\(corrections.count) corrections")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color(.controlBackgroundColor))
                                    .cornerRadius(8)
                            }
                            
                            // Corrections grid
                            LazyVGrid(columns: [
                                GridItem(.flexible(), alignment: .leading),
                                GridItem(.flexible(), alignment: .leading)
                            ], spacing: 8) {
                                ForEach(corrections.indices, id: \.self) { correctionIndex in
                                    let (original, replacement) = corrections[correctionIndex]
                                    
                                    HStack(spacing: 8) {
                                        Text("\"\(original)\"")
                                            .font(.system(.caption, design: .monospaced))
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 8))
                                            .foregroundColor(.secondary)
                                        
                                        Text("\"\(replacement)\"")
                                            .font(.system(.caption, design: .monospaced))
                                            .foregroundColor(.primary)
                                            .fontWeight(.medium)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.textBackgroundColor))
                                    .cornerRadius(4)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text("Impact Statistics")
                            .font(.headline)
                        
                        HStack(spacing: 24) {
                            VStack(spacing: 4) {
                                Text("99%")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                Text("Git Command")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Failure Rate")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 4) {
                                Text("15-50")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Text("Daily Uses")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Per Developer")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 4) {
                                Text("85-98%")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                Text("Acronym")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Failure Rate")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.textBackgroundColor))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .frame(width: 700, height: 600)
    }
}

#Preview {
    DeveloperVocabularyView()
}