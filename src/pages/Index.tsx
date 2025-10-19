import Hero from "@/components/Hero";
import Features from "@/components/Features";
import Installation from "@/components/Installation";

const Index = () => {
  return (
    <div className="min-h-screen">
      <Hero />
      <Features />
      <Installation />
      
      <footer className="border-t border-border py-8 px-4 text-center text-sm text-muted-foreground">
        <p>Ubuntu Dev Setup • Open Source • Safe & Reproducible</p>
      </footer>
    </div>
  );
};

export default Index;
