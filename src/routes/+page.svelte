<script context="module" lang="ts">
	// https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292722
	const STATIC_ATTRIBUTES = ['linkquality'];
</script>

<script lang="ts">
	// https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292707
	import { config } from '$lib/_config';
	import DeviceCard from './_DeviceCard.svelte';
	import EditCard from './_EditCard.svelte';
	import Stats from './_Stats.svelte';
	import { isDict } from '$lib/_utils';
	import { Tabs, TabItem } from 'flowbite-svelte';
	import { onMount } from 'svelte';
	import { source } from 'sveltekit-sse';

	/** @type {import('./$types').PageData */
	export let data;
	let { device_data, device_attributes, stats } = data;
	$: ({ device_data, device_attributes, stats } = data); // so it stays in sync when `data` changes
	let activeClasses =
		'inline-block text-sm font-medium text-center disabled:cursor-not-allowed p-4 text-blue-600 border-b-2 border-blue-600 dark:text-blue-500 dark:border-blue-500 active';

	$: console.log(device_attributes);

	let devices: { [key: string]: { [key: string]: any } } = {};
	$: {
		let tmp: { [key: string]: {} } = {};
		console.log(device_data);
		console.log(device_attributes);
		for (const ieeeAddr in device_data) {
			tmp[ieeeAddr] = prepareDevice(device_data[ieeeAddr]);
		}
		devices = tmp;
	}

	let updateStream;

	function prepareDevice(dev: { [key: string]: any }) {
		console.log(dev);
		console.log('a');
		return {
			device: {
				...dev,
				attributes: dev['attributes'].reduce((accumulator, value) => {
					return {
						...accumulator,
						[value]:
							dev['ieeeAddr'] in device_attributes &&
							device_attributes[dev['ieeeAddr']].indexOf(value) >= 0
								? false
								: true
					};
				}, {}),
				editFunc: triggerEdit,
				saveFunc: saveEdit,
				cancelFunc: cancelEdit
			},
			component: DeviceCard as unknown as DeviceCard | EditCard,
			old: {} as { [key: string]: boolean }
		};
	}

	function updateDevice(ieeeAddr, newDevice) {
		newDevice['attributes'] = [...newDevice['attributes'], ...STATIC_ATTRIBUTES];
		devices[ieeeAddr]['device'] = {
			...devices[ieeeAddr]['device'],
			...newDevice,
			attributes: newDevice['attributes'].reduce((accumulator, value) => {
				return {
					...accumulator,
					[value]:
						value in devices[ieeeAddr]['device']['attributes']
							? devices[ieeeAddr]['device']['attributes'][value]
							: ieeeAddr in device_attributes && device_attributes[ieeeAddr].indexOf(value) >= 0
								? false
								: true
				};
			}, {})
		};
	}

	function handleDevice(sseDevice) {
		if (sseDevice['remove'] === true) {
			console.log('remove');
			delete devices[sseDevice['ieeeAddr']];
			devices = { ...devices };
			console.log(devices);
		} else if (sseDevice['ieeeAddr'] in devices) {
			updateDevice(sseDevice['ieeeAddr'], sseDevice);
		} else {
			devices[sseDevice['ieeeAddr']] = prepareDevice(sseDevice);
		}
	}

	onMount(async () => {
		// get devices initially per sse, in case they changed after the server side rendering
		console.log('http://' + window.location.hostname + ':' + config.sse_port);
		source(
			(config.sse_addr || 'http://' + window.location.hostname + ':' + config.sse_port) + '/sse'
		)
			.select('init')
			.subscribe(async (value) => {
				if (!value) {
					return;
				}
				console.log(value);
				console.log(JSON.parse(value));

				let sseDevices: { [key: string]: any } = JSON.parse(value) as {};
				for (const ieeeAddr in sseDevices) {
					handleDevice(sseDevices[ieeeAddr]);
					// if (ieeeAddr in devices) {
					// 	updateDevice(ieeeAddr, sseDevices[ieeeAddr]);
					// } else {
					// 	devices[ieeeAddr] = prepareDevice(sseDevices[ieeeAddr]);
					// }
				}
				// console.log(sseDevices);
			});

		//get changed or new devices per sse
		source(
			(config.sse_addr || 'http://' + window.location.hostname + ':' + config.sse_port) + '/sse'
		)
			.select('message')
			.subscribe(async (value) => {
				if (!value) {
					return;
				}
				console.log('updates');
				let sseDevice: { [key: string]: any } = JSON.parse(value) as {};
				handleDevice(sseDevice);
				// if (sseDevice['ieeeAddr'] in devices) {
				// 	updateDevice(sseDevice['ieeeAddr'], sseDevice);
				// } else {
				// 	devices[sseDevice['ieeeAddr']] = prepareDevice(sseDevice);
				// }
			});

		// get stats initially per sse, in case they changed after the server side rendering
		source(
			(config.sse_addr || 'http://' + window.location.hostname + ':' + config.sse_port) +
				'/sse/stats'
		)
			.select('init')
			.subscribe(async (value) => {
				if (!value) {
					return;
				}
				console.log('stats init');
				let sseStats: { [key: string]: any } = JSON.parse(value) as {};
				for (const key in sseStats) {
					if (isDict(sseStats[key])) {
						stats[key] = { ...stats[key], ...sseStats[key] };
					} else {
						stats[key] = sseStats[key];
					}
				}
			});

		updateStream = source(
			(config.sse_addr || 'http://' + window.location.hostname + ':' + config.sse_port) +
				'/sse/stats'
		).select('message');
		// //get changed or new stats per sse
		// streamable({
		// 	url:
		// 		(config.sse_addr || 'http://' + window.location.hostname + ':' + config.sse_port) +
		// 		'/sse/stats',
		// 	event: 'message'
		// }).subscribe(async (value) => {
		// 	console.log('stats update');
		// 	let sseStats: { [key: string]: any } = (await value) as {};
		// 	for (const key in sseStats) {
		// 		console.log(sseStats);
		// 		if (sseStats[key] === null && stats[key] !== undefined) {
		// 			delete stats[key];
		// 		} else if (isDict(sseStats[key])) {
		// 			const obj = { ...stats[key], ...sseStats[key] };
		// 			Object.keys(obj).forEach((k) => obj[k] == null && delete obj[k]);
		// 			stats[key] = obj;
		// 		} else {
		// 			stats[key] = sseStats[key];
		// 		}
		// 	}
		// });
	});

	let statUnsubscribe = undefined;

	function listenStats() {
		//get changed or new stats per sse
		if (statUnsubscribe === undefined) {
			statUnsubscribe = updateStream.subscribe(async (value) => {
				if (!value) {
					return;
				}
				console.log('stats update');
				let sseStats: { [key: string]: any } = JSON.parse(value) as {};
				for (const key in sseStats) {
					console.log(sseStats);
					if (sseStats[key] === null && stats[key] !== undefined) {
						delete stats[key];
					} else if (isDict(sseStats[key])) {
						const obj = { ...stats[key], ...sseStats[key] };
						Object.keys(obj).forEach((k) => obj[k] == null && delete obj[k]);
						stats[key] = obj;
					} else {
						stats[key] = sseStats[key];
					}
				}
			});
		}
	}

	// let devices = [
	// 	{
	// 		device: {
	// 			devName: 'lumi.weather1',
	// 			ieeeAddr: '0x00158d0002310451',
	// 			manufName: 'LUMI',
	// 			attributes: {
	// 				temperature: true,
	// 				humidity: false,
	// 				pressure: true,
	// 				voltage: true,
	// 				battery: true
	// 			} as { [key: string]: boolean },
	// 			editFunc: triggerEdit,
	// 			cancelFunc: cancelEdit,
	// 			saveFunc: saveEdit
	// 		},
	// 		component: DeviceCard as unknown as DeviceCard | EditCard,
	// 		old: {} as { [key: string]: boolean }
	// 	},
	// 	{
	// 		device: {
	// 			devName: 'lumi.weather2',
	// 			ieeeAddr: '0x00158d0002310452',
	// 			manufName: 'LUMI',
	// 			attributes: {
	// 				temperature: true,
	// 				humidity: false,
	// 				pressure: true,
	// 				voltage: true,
	// 				battery: true
	// 			} as { [key: string]: boolean },
	// 			editFunc: triggerEdit,
	// 			cancelFunc: cancelEdit,
	// 			saveFunc: saveEdit
	// 		},
	// 		component: DeviceCard as unknown as DeviceCard | EditCard,
	// 		old: {} as { [key: string]: boolean }
	// 	}
	// ];

	function triggerEdit(ieeeAddr: string) {
		devices[ieeeAddr]['component'] = EditCard as unknown as DeviceCard | EditCard;
		devices[ieeeAddr]['old'] = { ...devices[ieeeAddr]['device']['attributes'] };
	}

	function cancelEdit(ieeeAddr: string) {
		devices[ieeeAddr]['device']['attributes'] = devices[ieeeAddr]['old'];
		devices[ieeeAddr]['component'] = DeviceCard as unknown as DeviceCard | EditCard;
	}

	function saveEdit(ieeeAddr: string) {
		devices[ieeeAddr]['component'] = DeviceCard as unknown as DeviceCard | EditCard;

		const res = fetch('device_attributes/' + ieeeAddr, {
			method: 'POST',
			body: JSON.stringify(
				Object.entries(devices[ieeeAddr]['device']['attributes'])
					.filter((x) => !x[1])
					.reduce((prev, cur) => [...prev, cur[0]], [] as string[])
			)
		});
	}
</script>

<Tabs class="mb-4 pl-4 pr-12" tabStyle="underline">
	<TabItem
		open
		title="Devices"
		on:click={() => {
			statUnsubscribe();
			statUnsubscribe = undefined;
		}}
	>
		<div
			class="grid grid-cols-1 place-items-center gap-8 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4"
		>
			{#each Object.entries(devices) as elem}
				<svelte:component this={elem[1]['component']} device={elem[1]['device']} />
			{/each}
		</div>
	</TabItem>
	<TabItem title="Configuration" on:click={listenStats}>
		<Stats {stats} />
	</TabItem>
</Tabs>
