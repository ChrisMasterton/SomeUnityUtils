using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameObjectAttractor : MonoBehaviour
{
    public List<GameObject> objects;
    public float strength = 1.0f;
    public float radius = 100.0f;

    public enum InfluenceType
    {
        Fixed,
        Linear,
        Ease,
    };

    public InfluenceType influenceType;
    public Easings.Functions easeFunction;
    
    
    void FixedUpdate()
    {
        float r2 = radius * radius;
        foreach (var go in objects)
        {
            Vector3 toAttractorVec = this.transform.position - go.transform.position;
            float dist2 = toAttractorVec.sqrMagnitude;
            if (dist2 <= r2)
            {
                if (dist2 > Mathf.Epsilon)
                {
                    // within influence.
                    float dist = Mathf.Sqrt(dist2);
                    float t = 1.0f - (dist / radius);
                    toAttractorVec /= dist;

                    float pull = 0.0f;
                    switch (influenceType)
                    {
                        case InfluenceType.Fixed:
                            pull = strength;
                            break;

                        case InfluenceType.Linear:
                            pull = t * strength;
                            break;

                        case InfluenceType.Ease:
                            pull = Easings.Interpolate(0.0f, strength, t, easeFunction);
                            break;
                    }

                    // move the pull to per second.
                    pull *= Time.fixedDeltaTime;

                    Vector3 pos = go.transform.position;
                    pos += pull * toAttractorVec;
                    go.transform.position = pos;
                }
            }
        }
    }
}
