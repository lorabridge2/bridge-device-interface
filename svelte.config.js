import adapter from '@sveltejs/adapter-node';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	// Consult https://svelte.dev/docs/kit/integrations
	// for more information about preprocessors
	preprocess: vitePreprocess(),

	kit: {
		adapter: adapter(),
		prerender: { crawl: false, concurrency: 0 }
	},
	compilerOptions: {
		customElement: true,
		compatibility: {
			componentApi: 4
		}
	},
};

export default config;
