using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Assertions;
using UnityEngine.SceneManagement;

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
        AddTags();
    }
    
    public void AddTags()
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

    
    #region expensive operation to refresh all active game objects and find taggy components - this will include inactive objects.

    public static void RefreshAllTags()
    {
        // We clear the contents rather than call new because it reduces gc.
        if (_tagLookups == null)
        {
            _tagLookups = new Dictionary<string, List<GameObject>>();
        }
        else
        {
            foreach (var tagList in _tagLookups.Values)
            {
                tagList.Clear();
            }
        }
        
        foreach (var taggyObject in FindAllObjectsOfTypeExpensive<Taggy>() )
        {
            taggyObject.AddTags();
        }
    }

    private static IEnumerable<GameObject> GetAllRootGameObjects()
    {
        for (int i = 0; i < SceneManager.sceneCount; i++)
        {
            var rootObjs = SceneManager.GetSceneAt(i).GetRootGameObjects();
            foreach (var obj in rootObjs)
                yield return obj;
        }
    }
 
    private static IEnumerable<T> FindAllObjectsOfTypeExpensive<T>()
        where T : MonoBehaviour
    {
        foreach (GameObject obj in GetAllRootGameObjects())
        {
            foreach (T child in obj.GetComponentsInChildren<T>(true))
                yield return child;
        }
    }
    #endregion
}
