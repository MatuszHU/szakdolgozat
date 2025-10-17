<script>
	let email = '';
	let password = '';
	let submitted = false;
	function handleLogin() {
		submitted = true;
		setTimeout(() => submitted = false, 1600);
	}
</script>

<div class="login-outer">
	<form class="login-card" on:submit|preventDefault={handleLogin}>
		<h1>Bejelentkezés</h1>
		<div class="fields">
			<div class="field">
				<label for="email">Email cím</label>
				<input id="email" type="email" bind:value={email} required autocomplete="username" />
			</div>
			<div class="field">
				<label for="password">Jelszó</label>
				<input id="password" type="password" bind:value={password} required autocomplete="current-password" />
			</div>
		</div>
		<button type="submit" disabled={submitted}>Belépés</button>
		{#if submitted}
			<div class="successmsg">✅ Sikeres bejelentkezés!</div>
		{/if}
	</form>
</div>

<style>
:global(body) {
	background: radial-gradient(ellipse 65% 60% at 55% 20%, #eaf8f0 75%, #f9faf6 100%);
	font-family: 'Segoe UI', Arial, sans-serif;
	margin: 0;
	padding: 0;
}
.login-outer {
	min-height: 100vh;
	display: flex;
	align-items: center;
	justify-content: center;
}
.login-card {
	background: #fff;
	border-radius: 1.6rem;
	box-shadow: 0 8px 40px #20613a16, 0 2px 0 #ffc82513;
	border: 2.5px solid #20613a;
	min-width: 330px;
	max-width: 97vw;
	padding: 2.15rem 2.3rem 2rem 2.3rem;
	display: flex;
	flex-direction: column;
	align-items: stretch;
	position: relative;
	gap: 1.2rem;
}
.login-card h1 {
	text-align: center;
	font-size: 1.35rem;
	letter-spacing: .02em;
	color: #20613a;
	margin-top: 0.25rem;
	margin-bottom: 0.5rem;
	font-weight: 900;
}
.fields {
	width: 100%;
	display: flex;
	flex-direction: column;
	gap: 0.85rem;
}
.field label {
	font-size: 1.04rem;
	font-weight: 700;
	color: #20613a;
	margin-bottom: 0.34em;
	display: block;
	letter-spacing: .01em;
}
.field input {
	width: 100%;
	padding: 0.9rem 1rem 0.8rem 1rem;
	background: #e9f7f2;
	border: 2px solid #b4e1cd;
	border-radius: 100px;
	font-size: 1.09rem;
	transition: border-color .16s, background .15s, box-shadow .13s;
	color: #144a27;
	box-shadow: 0 1.5px 4px #ffd2000c;
}
.field input:focus {
	border-color: #ffd200;
	background: #fffde9;
	box-shadow: 0 0 0 2.5px #ffd20030;
	outline: none;
}
button {
	margin-top: 0.7rem;
	background: linear-gradient(90deg, #ffd200 90%, #ffe15e 100%);
	color: #20613a;
	border: none;
	border-radius: 100px;
	padding: 1.09rem 0 1.02rem 0;
	width: 100%;
	font-size: 1.13rem;
	font-weight: bold;
	cursor: pointer;
	box-shadow: 0 8px 24px #ffd20026;
	transition: background .20s, filter .12s, transform .12s;
	letter-spacing: 0.03em;
}
button:hover {
	filter: brightness(1.05);
	background: linear-gradient(90deg, #ffe25e 70%, #ffd200 100%);
}
button:active {
	transform: scale(.98);
}
button:disabled {
	opacity: 0.68;
	cursor: not-allowed;
}
.successmsg {
	position: absolute;
	bottom: -40px;
	left: 50%;
	transform: translateX(-50%);
	background: #fffdc0;
	color: #20613a;
	padding: 0.68rem 1.18rem;
	border-radius: 13px;
	font-weight: 800;
	font-size: 1.04rem;
	box-shadow: 0 3px 10px #ffd20022;
	letter-spacing: .14px;
	border: 2px solid #ffe15e;
}
@media (max-width: 430px) {
	.login-card {
		min-width: 92vw;
		padding-left: 7vw;
		padding-right: 7vw;
	}
}
</style>
