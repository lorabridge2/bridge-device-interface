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
	const Z_INIT = 254;
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

<Card size="md" class="w-[25rem]">
	<div class="mb-5 flex justify-between"><h5 class="inline-block mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">Stats</h5>
	<Button class="w-1/2" color="blue" disabled={zcount>0 ?true:false} pill outline on:click={zjoin}>{zcount > 0 ? 'Join timeout: '+zcount+' sec' : 'Enable Zigbee join'}</Button></div>
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
						<TableBodyCell class="pr-6 text-right">{stats.temp.toFixed(2)} °C</TableBodyCell>
					</TableBodyRow>
				{/if}
				<TableBodyRow
					class="odd:bg-white even:bg-gray-100 dark:odd:bg-gray-800 dark:even:bg-gray-700"
				>
					<TableHeadCell scope="col" class="px-6 py-3">Last Boot:</TableHeadCell>
					<TableBodyCell class="w-5 pr-6 text-right break-words whitespace-break-spaces"
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