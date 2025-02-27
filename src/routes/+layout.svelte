<script>
	import '../app.css';
	import { Navbar, NavBrand, DarkMode } from 'flowbite-svelte';
	import logo from '$lib/assets/logo.webp';
	import { page } from '$app/stores';
	const btnClass =
		'text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700 focus:outline-hidden focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-700 rounded-lg text-lg p-2.5 fixed right-2 top-12  md:top-3 md:right-2 z-50';
</script>

<Navbar let:hidden let:toggle class="bg-white dark:bg-gray-900 text-gray-700 dark:text-gray-200 border-gray-100 dark:border-gray-700 px-2 sm:px-4 py-2.5 w-full">
	<NavBrand href="/">
		<img src={logo} class="mr-3 h-6 sm:h-9" alt="Lorabridge Logo" />
		<span class="self-center whitespace-nowrap text-xl font-semibold dark:text-white">
			Bridge-Devices
		</span>
	</NavBrand>
</Navbar>
<DarkMode {btnClass}></DarkMode>

<slot></slot>

<style>
	:global(nav) {
		border-bottom-width: 2px;
		margin-bottom: 1em;
	}
</style>
