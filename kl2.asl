state("kl2") 
{
	byte loadingScreenVisible : 0x00B64638; // True whenever there is a loading screen. Sometimes when alt-tabbed, will switch itself to 0.
	string80 loadingLevelWav : 0x010F3824; // Gives you the name of the level (actually, a wav file relating to the level) about 50% of the way through a load. Clears when loading is finished.
	byte cutsceneCandidate : 0x0116B3C6; // 0 when a cutscene is not playing, 2 when there is.
}

startup 
{
	settings.Add("pauseCutscenes", false, "Pause timer during cutscenes.");
	print("Hello, world!");
}

init 
{
	vars.old = old;

	Func<bool> isLoading = () => current.loadingScreenVisible == 1; // Current gets updated in place.
	Func<bool> wasLoading = () => vars.old.loadingScreenVisible == 1; // Old is a new object every time.
	Func<bool> startedLoading = () => isLoading() && !wasLoading();
	Func<bool> stoppedLoading = () => !isLoading() && wasLoading();
	
	
	Func<bool> inCutscene = () => current.cutsceneCandidate == 2;
	Func<bool> wasInCutscene = () => vars.old.cutsceneCandidate != 2;
	Func<bool> beganCutscene = () => inCutscene() && !wasInCutscene();
	Func<bool> finishedCutscene = () => !inCutscene() && wasInCutscene();
	
	bool startPrimed = false;
	
	Action tryPrimeStart = () => {
		if (!startPrimed) {
			startPrimed = vars.old.loadingLevelWav.StartsWith("SCENES\\Locations\\L01") && !current.loadingLevelWav.StartsWith("SCENES\\Locations\\L01");
		}
	};
	
	Func<bool> tryFireStart = () => {
		if (startPrimed && finishedCutscene()) {
			startPrimed = false;
			print("Run started, good luck!");
			return true;
		} else {
			return false;
		}
	};
	
	bool endingPrimed = false;
	
	Action tryPrimeEnd = () => {
		if (!endingPrimed) {
			endingPrimed = vars.old.loadingLevelWav.StartsWith("SCENES\\Locations\\L11") && !current.loadingLevelWav.StartsWith("SCENES\\Locations\\L11");
			if (endingPrimed) print("You're almost there, try not to crash...");
		}
	};
	
	Func<bool> tryFireEnd = () => {
		if (endingPrimed && beganCutscene()) {
			endingPrimed = false;
			print("You did it, congrats!");
			return true;
		} else {
			return false;
		}
	};
	
	Action forceResetPrimes = () => {
		startPrimed = false;
		endingPrimed = false;
	};

	vars.IsLoading = isLoading;
	vars.WasLoading = wasLoading;
	vars.StartedLoading = startedLoading;
	vars.InCutscene = inCutscene;
	vars.BeganCutscene = beganCutscene;
	vars.TryPrimeStart = tryPrimeStart;
	vars.TryFireStart = tryFireStart;
	vars.TryPrimeEnd = tryPrimeEnd;
	vars.TryFireEnd = tryFireEnd;
	vars.ForceResetPrimes = forceResetPrimes;
}

update
{
	vars.old = old;
	vars.TryPrimeStart();
	vars.TryPrimeEnd();
}

isLoading 
{	
	return vars.IsLoading() || (settings["pauseCutscenes"] && vars.InCutscene());
}

start
{
	return vars.TryFireStart();
}

split
{
	// The extra condition on the end is to prevent weirdness somewhere. I've forgotten.
	return vars.StartedLoading() || vars.TryFireEnd();
}

reset
{
	// Intro scene flash-forward... flash-present?
	if (current.loadingLevelWav.StartsWith("SCENES\\Locations\\L00")) {
		vars.ForceResetPrimes();
		return true;
	} else {
		return false;
	}
}
