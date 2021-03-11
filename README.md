# SomeUnityUtils
Mostly standalone Unity utilities that I would lose if I didn't put them somewhere. Last tested on Unity 2020.1.0f.


# Taggy
Apply tags to GameObjects at runtime or through the Unity editor. You can apply multiple tags to a single object.

Search for all objects with a specific tag:
	List<GameObject> Taggy.Find(string objectsWithThisTag);

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

