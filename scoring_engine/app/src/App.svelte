<script>
	import { onMount } from 'svelte';

	export let debugMode;
	export let competitionName;

	let serviceRegistry = {};
	let chart;

	// Thar be dragons! 🐲
	// The initial hack is done in the `services` variable which does some some hacky things
	// but totally works. It basically just grabs the "services" key from the `serviceRegistry`
	// object and defaults to an empty array so the other functions fail gracefully until
	// the API responds to properly populate these variables.
	$: services      = Object.entries(serviceRegistry).map(e => { if(e.length == 2) { return e[1] } else { return [{}] }})[0] || []
	$: teamNames     = Object.entries(services).map(serviceEntry => {return serviceEntry[0]})
	$: serviceKinds  = Array.from(new Set(Object.entries(services).map(serviceEntry => {return serviceEntry[1].map(service => service.kind)}).flat()))
	$: serviceSeries = Object.entries(services).map(serviceEntry => { return { name: serviceEntry[0], data: serviceEntry[1].map(s => s.points) }})

	$: if (serviceKinds.length > 0 && chart != undefined) {
		chart.updateOptions({
			xaxis: {
				categories: serviceKinds,
			},
			series: serviceSeries
		}, false, true, true)
	}

	let apexChartOptions = {
		chart: {
			height: 430,
			type: 'bar'
		},
		plotOptions: {
			bar: {
			horizontal: true,
				dataLabels: {
					position: 'top',
				}
			}
		},
		dataLabels: {
			enabled: true,
			offsetX: -6,
			style: {
				fontSize: '12px',
				colors: ['#fff']
			}
		},
		stroke: {
			show: true,
			width: 1,
			colors: ['#fff']
		},
		series: [],
		xaxis: {
			categories: [],
		}
	}

	function servicesForTeam(teamName) {
		if (Object.entries(serviceRegistry).length <= 0) {
			return [];
		}
		return serviceRegistry.services[teamName]
	}


	function openTeamModal(teamName) {
		document.querySelector(`#${teamName}`).classList.add("is-active")
	}

	function closeTeamModal(teamName) {
		document.querySelector(`#${teamName}`).classList.remove("is-active")
	}

	function sleep(ms) {
  		return new Promise(resolve => setTimeout(resolve, ms));
	}

	// fetchServiceRegistry handles asynchronously polling the backend API
	// for the most current service registry information.
	async function fetchServiceRegistry() {
		console.log("Polling API for information")
		if (debugMode) {
			if (Object.entries(serviceRegistry).length <= 0) {
				sleep(400)
				serviceRegistry = JSON.parse(`{"services":{"team-1":[{"kind":"http","ip":"192.168.1.2","port":80,"points":0,"protocol":"tcp"},{"kind":"mysql","ip":"192.168.1.2","port":3306,"points":0,"protocol":"tcp"},{"kind":"ssh","ip":"192.168.1.3","port":22,"points":44,"protocol":"tcp"},{"kind":"rdp","ip":"192.168.1.4","port":3389,"points":44,"protocol":"tcp"},{"kind":"ldap","ip":"192.168.1.4","port":389,"points":0,"protocol":"tcp"},{"kind":"mssql","ip":"192.168.1.4","port":1433,"points":0,"protocol":"tcp"}],"team-2":[{"kind":"http","ip":"192.168.2.2","port":80,"points":0,"protocol":"tcp"},{"kind":"mysql","ip":"192.168.2.2","port":3306,"points":0,"protocol":"tcp"},{"kind":"ssh","ip":"192.168.2.3","port":22,"points":44,"protocol":"tcp"},{"kind":"rdp","ip":"192.168.2.4","port":3389,"points":44,"protocol":"tcp"},{"kind":"ldap","ip":"192.168.2.4","port":389,"points":0,"protocol":"tcp"},{"kind":"mssql","ip":"192.168.2.4","port":1433,"points":0,"protocol":"tcp"}]}}`)
			} else {
				for (let [teamName, services] of Object.entries(serviceRegistry.services)) {
					services.map(service => {
						if ((Math.floor(Math.random() * 2) == 0)) {
							service.points += 1
						}
					})
					serviceRegistry.services[teamName] = services
				}
			}
		} else {
          const response = await fetch(document.location.href + "api/v1/service_registry");
          serviceRegistry = await response.json();
		}
		console.log(serviceRegistry)
	}

	onMount(async () => {
	// When the page loads, fetch the service registry from the backend API
	// and every 60 seconds ( 1 minute ) the service registry will be re-freshed
	// with new information from the API.
	fetchServiceRegistry()
	setInterval(function() {
		console.log("Polling the API")
		fetchServiceRegistry()
	}, 5 * 1000);

		// Setup the scoringe engine chart
		chart = new ApexCharts(
			document.querySelector("#chart"),
			apexChartOptions
		);
		chart.render();
	});

</script>

<nav class="navbar is-dark" role="navigation">
    <div class="navbar-brand">
      <a class="navbar-item" href="#">
        <i class="fas fa-rocket" style="padding-right: 5px;"></i><strong>{competitionName}</strong>
      </a>
    </div>
</nav>

<div id="teamMenu">
    <div class="tabs is-medium is-right">
      <ul>
			{#each teamNames as teamName}
				<li><a on:click="{() => openTeamModal(teamName)}" >{teamName}</a></li>
				<div id="{teamName}" class="modal">
					<div class="modal-background"></div>
					<div class="modal-card">
						<header class="modal-card-head">
							<p class="modal-card-title"><strong>{teamName}</strong></p>
							<button class="delete" aria-label="close" on:click="{() => closeTeamModal(teamName)}"></button>
						</header>
						<section class="modal-card-body">
							<table class="table">
								<thead>
									<tr>
									<th>Service</th>
									<th>Protocol</th>
									<th>IP</th>
									<th>Port</th>
									<th>Points</th>
									</tr>
								</thead>
								<tbody>
									{#each servicesForTeam(teamName) as service}
										<tr>
											<td>{service.kind}</td>
											<td>{service.protocol}</td>
											<td>{service.ip}</td>
											<td>{service.port}</td>
											<td>{service.points}</td>
										</tr>
									{/each}
								</tbody>
							</table>
							<!-- Content ... -->
						</section>
						<footer class="modal-card-foot"></footer>
					</div>
				</div>
			{/each}
      </ul>
    </div>
</div>

<section class="section">
    <div id="chart" class="section">
    </div>
</section>

<footer class="footer" style="position: absolute; bottom: 0; width: 100%; height: 1rem;">
    <div class="content has-text-centered">
      <p>
      	Made with <strong><span style="color: red">♥</span></strong> by <strong>Kent 'picat' Gruber</strong>
      </p>
    </div>
</footer>