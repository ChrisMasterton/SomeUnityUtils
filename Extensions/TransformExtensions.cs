using System;
using UnityEngine;

public static class TransformExtensions
{
    // Useful for cleaning up scroll group contents
    public static void DetachAndDestroyChildren(this Transform transform)
    {
        int total = transform.childCount;
        for (int i = total-1; i >= 0; i--)
        {
            GameObject.Destroy(transform.GetChild(i).gameObject);
        }
    }

    // This is used to fit scrollview transforms to the length of their children.
    public static void FitToChildLength(this RectTransform rt, float buffer = 0.0f )
    {
        if (rt.childCount > 0)
        {
            var lastChild = rt.GetChild(rt.childCount - 1) as RectTransform;
            if (lastChild != null)
            {
                float lastY = lastChild.position.y + lastChild.sizeDelta.y + buffer;
                rt.sizeDelta = new Vector2(rt.sizeDelta.x, lastY);
            }
        }
    }
}
