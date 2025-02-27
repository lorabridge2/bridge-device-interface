<script lang="ts">
	export let stats: { [key: string]: any };
	import {
		Button,
		Card,
		Table,
		TableBody,
		TableBodyCell,
		TableBodyRow,
		TableHeadCell
	} from 'flowbite-svelte';
	console.log(stats);
	const Z_INIT = 300;
	let lock = false;
	let zcount = 0;

	function zjoin() {
		if (lock === false) {
			lock = true;
			zcount = Z_INIT;
			fetch('stats/zigbee/join', { method: 'POST' });
			setTimeout(handleCounter, 1000);
		}
	}
	function handleCounter() {
		zcount--;
		if (zcount > 0) {
			setTimeout(handleCounter, 1000);
		} else {
			lock = false;
		}
	}
</script>

<Card size="sm">
	<h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">Stats</h5>
	<p class="font-normal text-gray-700 dark:text-gray-400">
		<Table divClass="relative overflow-x-auto sm:rounded-lg border-2 border-dashed">
			<TableBody>
				<TableBodyRow
					class="odd:bg-white even:bg-gray-100 dark:odd:bg-gray-800 dark:even:bg-gray-700"
				>
					<TableHeadCell scope="col" class="px-6 py-3">Device EUI:</TableHeadCell>
					<TableBodyCell class="pr-6 text-right">{stats.deveui}</TableBodyCell>
				</TableBodyRow>
				{#each Object.entries(stats.interfaces) as elem}
					<TableBodyRow
						class="odd:bg-white even:bg-gray-50 dark:odd:bg-gray-800 dark:even:bg-gray-700"
					>
						<TableHeadCell scope="col" class="px-6 py-3">{elem[0]}:</TableHeadCell>
						<TableBodyCell class="pr-6 text-right">{elem[1]}</TableBodyCell>
					</TableBodyRow>
				{/each}
				<TableBodyRow
					class="odd:bg-white even:bg-gray-100 dark:odd:bg-gray-800 dark:even:bg-gray-700"
				>
					<TableHeadCell scope="col" class="px-6 py-3">CPU usage:</TableHeadCell>
					<TableBodyCell class="pr-6 text-right">{stats.cpu.toFixed(2)} %</TableBodyCell>
				</TableBodyRow>
				<TableBodyRow
					class="odd:bg-white even:bg-gray-100 dark:odd:bg-gray-800 dark:even:bg-gray-700"
				>
					<TableHeadCell scope="col" class="px-6 py-3">Avail memory:</TableHeadCell>
					<TableBodyCell class="pr-6 text-right">{stats.mem.toFixed(2)} %</TableBodyCell>
				</TableBodyRow>
				<TableBodyRow
					class="odd:bg-white even:bg-gray-100 dark:odd:bg-gray-800 dark:even:bg-gray-700"
				>
					<TableHeadCell scope="col" class="px-6 py-3">Free disk space:</TableHeadCell>
					<TableBodyCell class="pr-6 text-right">{stats.disk.toFixed(2)} %</TableBodyCell>
				</TableBodyRow>
				{#if stats.temp}
					<TableBodyRow
						class="odd:bg-white even:bg-gray-100 dark:odd:bg-gray-800 dark:even:bg-gray-700"
					>
						<TableHeadCell scope="col" class="px-6 py-3">Temperature:</TableHeadCell>
						<TableBodyCell class="pr-6 text-right">{stats.temp.toFixed(2)} %</TableBodyCell>
					</TableBodyRow>
				{/if}
				<TableBodyRow
					class="odd:bg-white even:bg-gray-100 dark:odd:bg-gray-800 dark:even:bg-gray-700"
				>
					<TableHeadCell scope="col" class="px-6 py-3">Last Boot:</TableHeadCell>
					<TableBodyCell class="pr-6 text-right break-words whitespace-break-spaces"
						>{new Date(stats.uptime).toUTCString()}</TableBodyCell
					>
				</TableBodyRow>
				<TableBodyRow
					class="odd:bg-white even:bg-gray-100 dark:odd:bg-gray-800 dark:even:bg-gray-700"
				>
					<TableHeadCell scope="col" class="px-6 py-3">Zigbee2mqtt:</TableHeadCell>
					<TableBodyCell class="pr-6 text-right">{stats.zigbee.status}</TableBodyCell>
				</TableBodyRow>
				<TableBodyRow
					class="odd:bg-white even:bg-gray-100 dark:odd:bg-gray-800 dark:even:bg-gray-700"
				>
					<TableHeadCell scope="col" class="px-6 py-3">Zigbee devices:</TableHeadCell>
					<TableBodyCell class="pr-6 text-right">{stats.zigbee.devices}</TableBodyCell>
				</TableBodyRow>
				<TableBodyRow
					class="odd:bg-white even:bg-gray-100 dark:odd:bg-gray-800 dark:even:bg-gray-700"
				>
					<TableHeadCell scope="col" class="px-6 py-3">LoRaWAN TX:</TableHeadCell>
					<TableBodyCell class="pr-6 text-right">{stats.lorawan.txstatus}</TableBodyCell>
				</TableBodyRow>
				<TableBodyRow
					class="odd:bg-white even:bg-gray-100 dark:odd:bg-gray-800 dark:even:bg-gray-700"
				>
					<TableHeadCell scope="col" class="px-6 py-3">TX queue length:</TableHeadCell>
					<TableBodyCell class="pr-6 text-right">{stats.lorawan.queueLength}</TableBodyCell>
				</TableBodyRow>
			</TableBody>
		</Table>
	</p>
</Card>

<div class="mt-8">
	<Button color="blue" pill outline on:click={zjoin}>Enable Zigbee join</Button>
	<span
		class="mb-2 ml-5 inline-block text-lg font-medium tracking-tight text-gray-900 dark:text-white"
		style="visibility: {zcount > 0 ? 'visible' : 'hidden'}">Join timeout: {zcount} sec</span
	>
</div>
