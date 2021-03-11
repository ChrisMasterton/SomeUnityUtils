using System;
using UnityEngine;
using UnityEngine.Assertions;

[CreateAssetMenu(fileName = "Data", menuName = "ScriptableObjects/Weighted Pool")]
public class WeightedPoolAsset : ScriptableObject
{
    [Serializable]
    public class Entry
    {
        public GameObject contextGameObject;	// but this can be anything really, an enum, int, string, prefab.
        public float weight;
    };

    public Entry[] entries;

    public Entry Random()
    {
        Assert.IsNotNull(entries, "Weighted Pool " + this.name + " has zero entries");
        
        var totalWeight = 0.0f; // this stores sum of weights of all elements before current
        var selected = entries[0];
        foreach (var entry in entries)
        {
            var r = UnityEngine.Random.value * (totalWeight + entry.weight); // random value
            if (r >= totalWeight) // probability of this is weight/(totalWeight+weight)
                selected = entry; // it is the probability of discarding last selected element and selecting current one instead
            totalWeight += entry.weight; // increase weight sum
        }
        Assert.IsNotNull(selected);

        return selected;
    }
}
