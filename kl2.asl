state("kl2") 
{
	byte loadingScreenVisible : 0x00B64638; // True whenever there is a loading screen. Sometimes when alt-tabbed, will switch itself to 0.
	string80 loadingLevelWav : 0x010F3824; // Gives you the name of the level (actually, a wav file relating to the level) about 50% of the way through a load. Clears when loading is finished.
	byte cutsceneCandidate : 0x0116B3C6; // 0 when a cutscene is not playing, 2 when there is.
}

init 
{
	vars.old = old;

	Func<bool> isLoading = () => current.loadingScreenVisible == 1; // Current gets updated in place.
	Func<bool> wasLoading = () => vars.old.loadingScreenVisible == 1; // Old is a new object every time.
	Func<bool> startedLoading = () => isLoading() && !wasLoading();
	Func<bool> stoppedLoading = () => !isLoading() && wasLoading();
	Func<bool> inCutscene = () => current.cutsceneCandidate == 2;
	
	vars.IsLoading = isLoading;
	vars.WasLoading = wasLoading;
	vars.StartedLoading = startedLoading;
	vars.StoppedLoading = stoppedLoading;
	vars.InCutscene = inCutscene;
}

startup 
{
	print("Hello, world!");
}

update
{
	vars.old = old;
}

isLoading 
{	
	// We don't want it when we've started loading because then it will cause split{} to not call.
	return vars.IsLoading() || vars.InCutscene();
}

start
{
	// May be nessessary to add '&& !current.startedLoading' because of timing.
	return old.loadingLevelWav.StartsWith("SCENES\\Locations\\L01") && !current.loadingLevelWav.StartsWith("SCENES\\Locations\\L01");
}

split
{
	// The extra condition on the end is to prevent weirdness somewhere. I've forgotten.
	return vars.StartedLoading();
}

reset
{
	// Intro scene flash-forward... flash-present?
	return current.loadingLevelWav.StartsWith("SCENES\\Locations\\L00");
}
