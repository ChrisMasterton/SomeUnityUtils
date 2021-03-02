/*
MIT License

Copyright (c) 2021 Chris Masterton

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Assertions;

public class Taggy : MonoBehaviour
{
    #region static inventory of tagged items
    private static Dictionary<string, List<GameObject>> _tagLookups = new Dictionary<string, List<GameObject>>();
    public static GameObject[] Find(string tag)
    {
        if (_tagLookups.ContainsKey(tag))
        {
            return _tagLookups[tag].ToArray();
        }
        return null;
    }
    
    public static GameObject[] FindExcept(string tag, GameObject exclude)
    {
        if (_tagLookups.ContainsKey(tag))
        {
            var lookups = _tagLookups[tag];
            if (lookups.Contains(exclude))
            {
                GameObject[] rval = new GameObject[lookups.Count - 1];
                int idx = 0;
                foreach (var go in lookups)
                {
                    if (go != exclude)
                        rval[idx++] = go;
                }
                Assert.IsTrue(rval.Length < lookups.Count);
                return rval;
            }
            else
            {
                return lookups.ToArray();
            }
        }
        return null;
    }

    private void AddTaggedObject(List<string> tags, GameObject go)
    {
        foreach (var tag in tags)
        {
            AddTaggedObject(tag, go);
        }
    }
    
    private void AddTaggedObject(string tag, GameObject go)
    {
        if (_tagLookups.ContainsKey(tag) == false)
            _tagLookups.Add(tag, new List<GameObject>());
        _tagLookups[tag].Add( go );
    }

    private static void RemoveTaggedObject(List<string> tags, GameObject go)
    {
        foreach( var tag in tags )
        {
            if (_tagLookups.ContainsKey(tag))
            {
                _tagLookups[tag].Remove(go);
            }
        }
    }
    
    private static void RemoveTaggedObject(string tag, GameObject go)
    {
        if (_tagLookups.ContainsKey(tag))
        {
            _tagLookups[tag].Remove(go);
        }
    }
    #endregion
    
    public List<string> tags;

    void OnEnable()
    {
        if( tags != null )
            AddTaggedObject(tags, this.gameObject);
    }

    void OnDisable()
    {
        if( tags != null )
            RemoveTaggedObject(tags, this.gameObject);
    }

    void AddRuntimeTag(string runtimeTag)
    {
        if (this.isActiveAndEnabled)
        {
            // its own tags were already sent to the system, add this single tag.
            tags.Add(runtimeTag);
            AddTaggedObject(runtimeTag, this.gameObject);
        }
        else
        {
            // we can add this tag to the objects own list, it will go into the tag system when the object becomes enabled.
            if (tags == null)
                tags = new List<string>();
            tags.Add(runtimeTag);
        }
    }
    
    void RemoveRuntimeTag(string runtimeTag)
    {
        if (tags != null)
        {
            tags.Remove(runtimeTag);
            RemoveTaggedObject(runtimeTag, this.gameObject);
        }
    }

    bool HasTag(string tagString)
    {
        foreach (var tag in this.tags)
        {
            if (tag == tagString)
                return true;
        }
        return false;
    }

    public static bool HasTag(GameObject go, string tagString)
    {
        Assert.IsNotNull(go);
        Assert.IsNotNull(tagString);
        Taggy t = go.GetComponent<Taggy>();
        if (t == null)
            return false;

        return t.HasTag(tagString);
    }
}
