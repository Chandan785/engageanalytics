import { Logo } from '@/components/Logo';
import { Link } from 'react-router-dom';
import { Button } from '@/components/ui/button';

const Support = () => {
  return (
    <div className="min-h-screen bg-background">
      <nav className="sticky top-0 z-40 bg-background/80 backdrop-blur-lg border-b border-border">
        <div className="container py-4 flex items-center justify-between">
          <Logo size="md" />
          <Link to="/">
            <Button variant="ghost">Home</Button>
          </Link>
        </div>
      </nav>

      <main className="container py-12">
        <div className="max-w-3xl mx-auto">
          <h1 className="text-3xl font-bold text-foreground mb-2">Support</h1>
          <p className="text-muted-foreground mb-8">We’re here to help. Choose an option below or email us directly.</p>

          <div className="grid gap-6 md:grid-cols-2">
            <div className="rounded-xl border border-border p-6 bg-card">
              <h2 className="text-lg font-semibold mb-2">Contact</h2>
              <p className="text-sm text-muted-foreground mb-4">Get in touch with our support team.</p>
              <a href="mailto:support@engageanalytic.me" className="text-primary hover:underline">support@engageanalytic.me</a>
            </div>
            <div className="rounded-xl border border-border p-6 bg-card">
              <h2 className="text-lg font-semibold mb-2">Documentation</h2>
              <p className="text-sm text-muted-foreground mb-4">Read setup guides and FAQs.</p>
              <Link to="/" className="text-primary hover:underline">Go to Website</Link>
            </div>
          </div>

          <div className="mt-10 rounded-xl border border-border p-6 bg-card">
            <h2 className="text-lg font-semibold mb-2">Status & Updates</h2>
            <p className="text-sm text-muted-foreground">No incidents reported. For urgent issues, email <a className="text-primary hover:underline" href="mailto:support@engageanalytic.me">support@engageanalytic.me</a>.</p>
          </div>
        </div>
      </main>
    </div>
  );
};

export default Support;
