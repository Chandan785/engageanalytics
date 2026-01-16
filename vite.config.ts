import { defineConfig } from "vite";
import react from "@vitejs/plugin-react-swc";
import path from "path";
import { componentTagger } from "lovable-tagger";

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  // Get the public URL from environment variable if running through tunnel
  const publicUrl = process.env.VITE_PUBLIC_URL || "http://localhost:8080";
  
  return {
    server: {
      host: "::",
      port: 8081,
      allowedHosts: [".trycloudflare.com"], // Allow Cloudflare tunnel domains
    },
    preview: {
      allowedHosts: [".trycloudflare.com"],
    },
    plugins: [react(), mode === "development" && componentTagger()].filter(Boolean),
    resolve: {
      alias: {
        "@": path.resolve(__dirname, "./src"),
      },
    },
  };
});
