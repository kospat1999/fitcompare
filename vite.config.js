import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 3000,
    open: true,
  },
  optimizeDeps: {
    include: ["@supabase/supabase-js"],
  },
  build: {
    commonjsOptions: {
      include: [/node_modules/],
    },
    sourcemap: false, // Wyłącz source maps w produkcji
  },
  css: {
    devSourcemap: false, // Wyłącz source maps dla CSS
  },
});
