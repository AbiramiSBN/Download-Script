import { CheckCircle2, Shield, Zap } from "lucide-react";

const Installation = () => {
  const steps = [
    {
      title: "Download or Copy",
      description: "Get the script via download or copy the install command",
      command: "curl -fsSL https://your-domain.com/install.sh | bash"
    },
    {
      title: "Make Executable",
      description: "If downloaded, make the script executable",
      command: "chmod +x ubuntu-dev-setup.sh"
    },
    {
      title: "Run Installation",
      description: "Execute the script with sudo privileges",
      command: "./ubuntu-dev-setup.sh"
    }
  ];

  const safetyFeatures = [
    {
      icon: Shield,
      title: "Safe to Re-run",
      description: "Script checks for existing installations and skips them"
    },
    {
      icon: CheckCircle2,
      title: "WSL Compatible",
      description: "Automatically detects WSL and adjusts installation accordingly"
    },
    {
      icon: Zap,
      title: "Official Sources",
      description: "Uses official repositories and trusted package sources"
    }
  ];

  return (
    <section className="py-24 px-4">
      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-16">
          <h2 className="text-4xl md:text-5xl font-bold mb-4">
            Quick Installation
          </h2>
          <p className="text-xl text-muted-foreground">
            Three simple steps to a fully configured dev environment
          </p>
        </div>

        <div className="grid lg:grid-cols-3 gap-8 mb-16">
          {steps.map((step, index) => (
            <div key={index} className="relative">
              <div className="terminal-window p-6">
                <div className="flex items-center gap-3 mb-4">
                  <div className="w-10 h-10 rounded-full bg-gradient-primary flex items-center justify-center text-primary-foreground font-bold">
                    {index + 1}
                  </div>
                  <h3 className="text-xl font-semibold">{step.title}</h3>
                </div>
                <p className="text-muted-foreground mb-4">{step.description}</p>
                <div className="bg-secondary p-4 rounded-lg font-mono text-sm overflow-x-auto">
                  <code className="text-foreground">{step.command}</code>
                </div>
              </div>
              {index < steps.length - 1 && (
                <div className="hidden lg:block absolute top-1/2 -right-4 transform -translate-y-1/2">
                  <div className="text-primary text-2xl">→</div>
                </div>
              )}
            </div>
          ))}
        </div>

        <div className="grid md:grid-cols-3 gap-6">
          {safetyFeatures.map((feature, index) => (
            <div key={index} className="terminal-window p-6 text-center">
              <div className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-gradient-accent mb-4">
                <feature.icon className="w-6 h-6 text-accent-foreground" />
              </div>
              <h3 className="text-lg font-semibold mb-2">{feature.title}</h3>
              <p className="text-sm text-muted-foreground">{feature.description}</p>
            </div>
          ))}
        </div>

        <div className="mt-12 terminal-window p-8">
          <h3 className="text-2xl font-semibold mb-4">System Requirements</h3>
          <div className="grid md:grid-cols-2 gap-6 text-muted-foreground">
            <div>
              <h4 className="text-foreground font-medium mb-2">✓ Supported Systems</h4>
              <ul className="space-y-1 text-sm">
                <li>• Ubuntu 20.04 LTS or newer</li>
                <li>• Ubuntu on WSL2</li>
                <li>• Debian-based distributions</li>
                <li>• Both x86_64 and ARM64 architectures</li>
              </ul>
            </div>
            <div>
              <h4 className="text-foreground font-medium mb-2">✓ Prerequisites</h4>
              <ul className="space-y-1 text-sm">
                <li>• Sudo/root access</li>
                <li>• Active internet connection</li>
                <li>• 10GB+ free disk space</li>
                <li>• curl or wget installed</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Installation;
