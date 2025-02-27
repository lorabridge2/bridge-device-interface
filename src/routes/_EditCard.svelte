<script lang="ts">
	import { Card, Table, Button, Toggle, ButtonGroup, TableBody, TableBodyRow, TableHeadCell, TableBodyCell } from 'flowbite-svelte';
	import { CheckOutline, CloseOutline } from 'flowbite-svelte-icons';
	export let device: {
		devName: string;
		ieeeAddr: string;
		manufName: string;
		attributes: { [key: string]: boolean };
		cancelFunc: Function;
		saveFunc: Function;
		editFunc?: Function;
	};
	$: ({ devName, ieeeAddr, manufName, attributes, cancelFunc, saveFunc, editFunc } = device);

	let defaultClasses =
		'inline-flex items-center py-0.5 px-1 text-xs font-medium first:rounded-l-lg border-t border-b last:rounded-r-md border-l last:border-r focus:z-10 focus:ring-2';
</script>

<Card>
	<h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
		{devName}
	</h5>
	<p class="font-normal text-gray-700 dark:text-gray-400">
		<Table divClass="relative overflow-x-auto sm:rounded-lg border-2 border-dashed">
			<!-- <TableDefaultRow items={itemEx} html /> -->
			 <TableBody>
			<TableBodyRow class="odd:bg-white even:bg-gray-100 dark:odd:bg-gray-800 dark:even:bg-gray-700">
				<TableHeadCell scope="col" class="px-6 py-3">ieeeAddr</TableHeadCell>
				<TableBodyCell class="pr-4">{ieeeAddr}</TableBodyCell>
			</TableBodyRow>
			<TableBodyRow class="odd:bg-white even:bg-gray-100 dark:odd:bg-gray-800 dark:even:bg-gray-700">
				<TableHeadCell scope="col" class="px-6 py-3">manufName</TableHeadCell>
				<TableBodyCell class="pr-4">{manufName}</TableBodyCell>
			</TableBodyRow>
			<TableBodyRow class="odd:bg-white even:bg-gray-100 dark:odd:bg-gray-800 dark:even:bg-gray-700">
				<TableHeadCell scope="col" class="px-6 py-3">Attributes</TableHeadCell>
				<TableBodyCell class="pr-4">
					<ul class="text-sm font-medium">
						{#each Object.entries(attributes) as [attribute, enabled]}
							<li class="py-1">
								<Toggle
									size="small"
									value="{ieeeAddr}-{attribute}-toggle"
									name="{ieeeAddr}-{attribute}-toggle"
									id="{ieeeAddr}-{attribute}-toggle"
									bind:checked={device['attributes'][attribute]}>{attribute}</Toggle
								>
							</li>
						{/each}
					</ul></TableBodyCell
				>
			</TableBodyRow>
			</TableBody>
		</Table>
		<span class="float-right space-x-2 mt-2">
			<ButtonGroup>
				<Button
					on:click={() => {
						saveFunc(ieeeAddr);
					}}
					class="text-xs text-green-700 hover:text-white border border-green-700 hover:bg-green-800 focus:ring-green-300 dark:border-green-500 dark:text-green-500 dark:hover:text-white dark:hover:bg-green-600 dark:focus:ring-green-800 "
					><CheckOutline  /></Button
				>
				<Button
					on:click={() => {
						cancelFunc(ieeeAddr);
					}}
					class="text-xs text-red-700 hover:text-white border border-red-700 hover:bg-red-800 focus:ring-red-300 dark:border-red-500 dark:text-red-500 dark:hover:text-white dark:hover:bg-red-600 dark:focus:ring-red-900"
					><CloseOutline /></Button
				>
			</ButtonGroup>
		</span>
	</p>
</Card>
