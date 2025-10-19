import { Code, Database, Cloud, Terminal, Wrench, Sparkles } from "lucide-react";

const Features = () => {
  const features = [
    {
      icon: Code,
      title: "Multi-Language Support",
      items: ["C/C++ (Clang, GCC)", "Python (3.x + pipx)", "Rust (cargo)", "Node.js (nvm)", "Go", "Java 21", ".NET 8"],
      color: "text-primary"
    },
    {
      icon: Database,
      title: "Database Tools",
      items: ["PostgreSQL client", "MongoDB Shell", "Redis CLI", "SQLite3", "DBeaver CE", "pgcli"],
      color: "text-accent"
    },
    {
      icon: Cloud,
      title: "Cloud & DevOps",
      items: ["Docker & Podman", "Kubernetes (kubectl, helm)", "AWS CLI", "Azure CLI", "Google Cloud SDK", "Terraform & Packer"],
      color: "text-primary"
    },
    {
      icon: Terminal,
      title: "Enhanced CLI",
      items: ["Starship prompt", "Modern tools (ripgrep, fd, bat, eza)", "Git + Git LFS", "tmux & screen", "Neovim", "fzf"],
      color: "text-accent"
    },
    {
      icon: Wrench,
      title: "Development Tools",
      items: ["VS Code", "Qt Creator", "Docker Desktop", "k9s & stern", "GitHub CLI", "OpenTofu"],
      color: "text-primary"
    },
    {
      icon: Sparkles,
      title: "AI & ML Stack",
      items: ["PyTorch & TensorFlow", "ONNX Runtime", "Jupyter Lab", "CUDA support (auto-detect)", "OpenVINO", "GPU-aware setup"],
      color: "text-accent"
    }
  ];

  return (
    <section className="py-24 px-4 relative">
      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-16">
          <h2 className="text-4xl md:text-5xl font-bold mb-4">
            Everything You Need
          </h2>
          <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
            A complete development environment with all the tools, languages, and frameworks modern developers need.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {features.map((feature, index) => (
            <div
              key={index}
              className="terminal-window p-6 hover:border-primary/50 transition-all duration-300 hover:-translate-y-1"
            >
              <div className="flex items-center gap-3 mb-4">
                <div className={`p-2 rounded-lg bg-secondary ${feature.color}`}>
                  <feature.icon className="w-6 h-6" />
                </div>
                <h3 className="text-xl font-semibold">{feature.title}</h3>
              </div>
              <ul className="space-y-2">
                {feature.items.map((item, i) => (
                  <li key={i} className="flex items-start gap-2 text-sm text-muted-foreground">
                    <span className="text-primary mt-1">▸</span>
                    <span>{item}</span>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Features;
