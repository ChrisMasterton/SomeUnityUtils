using System;
using UnityEngine;

public static class GameObjectExtensions
{
    // Sets a gameobject as inactive if its currently active.
    // This is useful because reenabling an object thats already enabled
    // causes the onenable to be called agian. Which sucks if you have
    // setup code tied to that OnEnable.
    public static void SetActiveOnce(this GameObject obj, bool toState)
    {
        if (toState == true && obj.activeInHierarchy == false)
            obj.SetActive(true);
        else if (toState == false && obj.activeInHierarchy == true)
            obj.SetActive(false);
    }
}
