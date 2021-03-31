using UnityEngine;
using UnityEngine.UI;

public class RawImageAnimation : MonoBehaviour
{
    public int xUnits, yUnits;
    public int fixedUpdateFrames = 6;
    public bool loop = true;
    public bool destroyOnEnd = false;
    public bool randomStartFrame = false;
    
    private int _displayFrames;
    private RawImage _rawImage;
    private int _frame = 0;
    private int _totalFrames = 0;
    private float[] _u;
    private float[] _v;
    private float _w;
    private float _h;
    private Rect _rect;
    
    void Start()
    {
        _totalFrames = xUnits * yUnits;
        _rawImage = GetComponent<RawImage> ();
        _u = new float[_totalFrames];
        _v = new float[_totalFrames];
        _w = 1.0f / xUnits;
        _h = 1.0f / yUnits;

        int idx = 0;
        for (int y = 0; y < yUnits; y++)
        {
            for (int x = 0; x < xUnits; x++)
            {
                _u[idx] = _w * (float)x;
                _v[idx] = _h * (float)y;
                idx++;
            }
        }

        _rect = new Rect(0.0f, 0.0f, _w, _h);

        if (randomStartFrame)
        {
            _frame = UnityEngine.Random.Range(0, _totalFrames);
            _displayFrames = UnityEngine.Random.Range(0, fixedUpdateFrames);
        }
        else
        {
            _frame = 0;
            _displayFrames = fixedUpdateFrames;
        }
        UpdateUVS();
    }

    void UpdateUVS()
    {
        _rect.x = _u[_frame];
        _rect.y = _v[_frame];
        _rect.width = _w;
        _rect.height = _h;

        _rawImage.uvRect = _rect;
    }

    void FixedUpdate () 
    {
        _displayFrames--;
        if (_displayFrames <= 0)
        {
            _displayFrames = fixedUpdateFrames;
            _frame++;

            if (_frame >= _totalFrames)
            {
                if (destroyOnEnd)
                    Destroy(gameObject);
                else if( loop )
                    _frame = 0;
                else
                    _frame = _totalFrames - 1;
            }
            
            UpdateUVS(); 
        }
    }
}
