state("kl2") 
{
	bool startedLoading : 0x00B18C60; // True when loading starts. Flicks between true and false at the end of a level load, so terrible in co-op, if alt-tabbed, or waiting for dialogue to finish.
	string80 loadingLevelWav : 0x010F3824; // Gives you the name of the level (actually, a wav file relating to the level) about 50% of the way through a load. Clears immediately on level start.
	// So essentially I use startedLoading for the start of the load and loadingLevelWav for the end of one.
}

startup 
{
	print("Hello, world!");
}

isLoading 
{
	// Covers all loading cases.
	return current.startedLoading || current.loadingLevelWav.StartsWith("SCENES");
}

start
{
	// May be nessessary to add '&& !current.startedLoading' because of timing.
	return old.loadingLevelWav.StartsWith("SCENES\\Locations\\L01") && !current.loadingLevelWav.StartsWith("SCENES\\Locations\\L01");
}

split
{
	// The extra condition on the end is to prevent weirdness somewhere. I've forgotten.
	return current.startedLoading && !old.startedLoading && !current.loadingLevelWav.StartsWith("SCENES");
}

reset
{
	// Intro scene flash-forward... flash-present?
	return current.loadingLevelWav.StartsWith("SCENES\\Locations\\L00");
}

