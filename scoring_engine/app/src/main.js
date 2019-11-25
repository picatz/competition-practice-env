import App from './App.svelte';

const app = new App({
	target: document.body,
	props: {
		competitionName: 'YoloCTF',
		debugMode: false
	}
});

export default app;