import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

function watchStdin() {
  process.stdin.on('close', () => {
    process.exit(0)
  })

  process.stdin.resume()
}

export default defineConfig(({ mode: mode }) => {
  const isDevelopment = mode === 'development';

  if (isDevelopment) {
    watchStdin();
  }

  return {
    plugins: [svelte()],
    build: {
      outDir: '../priv/static/',
      emptyOutDir: false,
      manifest: false,
      assetsDir: 'assets',
      sourcemap: isDevelopment,
      minify: !isDevelopment,
      rollupOptions: {
        input: {
          main: "./src/main.js"
        },
        output: {
          entryFileNames: "assets/[name].js",
          chunkFileNames: "assets/[name].js",
          assetFileNames: "assets/[name][extname]"
        }
      }
    }
  }
})
