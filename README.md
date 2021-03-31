# SomeUnityUtils
Mostly standalone Unity utilities that I would lose if I didn't put them somewhere. Last tested on Unity 2020.1.0f.


# Taggy
Apply tags to GameObjects at runtime or through the Unity editor. You can apply multiple tags to a single object.

Search for all objects with a specific tag:
	List<GameObject> Taggy.Find(string objectsWithThisTag);
	
An alternative to having the GameObjects register themselves via Taggy is to call:
	Taggy.RefreshAllTags();

This finds all Taggy component in the loaded scene(s) and registers them. This is handy for registering components that start as disabled. It is expensive and should only be done on scene start as parses every child component loaded.

# Weighted Pool
Scriptable object useful for reward pools, or any time you want randomness but with pre-defined weights. I suppose you could also change the weights at runtime too.

Create the asset then add whatever objects you want to randomly pick between. You can use any range of values and it does not need to add up to 100 (or 1.0). The weights are relative to each other. For example:

Item: Crappy sword
Weight: 500

Item: Sparkly sword
Weight: 100

Item: Amazing super and totally the best sword
Weight: 5

WeightedPoolAsset.Random() will return you the weighted and random entry - which will mostly likely be a Crappy Sword because we have weighted is so highly compared to the others.


# RawImageAnimation
Animates the frames of a sprite sheet. Add this component to a gameobject with an existing RawImage component. It is easier to do animation with RawImages than a UI.Image because you can adjust the UV's. The animation timing is counted in frames and occurs in FixedUpdate. If you increase the rate of your FixedUpdate (and why would you?) you will need to adjust the frame timing.


