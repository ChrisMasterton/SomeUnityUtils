using System;
using UnityEngine;

public static class StringExtensions
{
    public static string ToGameString(this TimeSpan ts)
    {
        // 5d 4h 23m 03s
        // 4h 23m 24s
        // 23m 08s
        // 7s
        string txt = "";
        if (ts.TotalHours >= 24)
            txt += ts.Days.ToString() + "d ";
        if (ts.TotalMinutes >= 60)
            txt += ts.Hours.ToString() + "h ";
        if (ts.TotalSeconds >= 60)
            txt += ts.Minutes.ToString() + "m ";
        txt += ts.Seconds.ToString() + "s";
        return txt;
    }
    
    public static string ToEnglishOrdinalString(this string txt)
    {
        // -st is used with numbers ending in 1 (e.g. 1st, pronounced first)
        // -nd is used with numbers ending in 2 (e.g. 92nd, pronounced ninety-second)
        // -rd is used with numbers ending in 3 (e.g. 33rd, pronounced thirty-third)
        // As an exception to the above rules, all the "teen" numbers ending
        // with 11, 12 or 13 use -th (e.g. 11th, pronounced eleventh, 112th,
        // pronounced one hundred [and] twelfth)
        // -th is used for all other numbers (e.g. 9th, pronounced ninth). 
        int len = txt.Length;
        if (len > 1 && txt[len-2] == '1' )
        {
            return (txt + "th");
        }
        else if (txt[len - 1] == '1')
        {
            return (txt + "st");
        }
        else if (txt[len - 1] == '2')
        {
            return (txt + "nd");
        }
        else if (txt[len - 1] == '3')
        {
            return (txt + "rd");
        }
        else
        {
            return (txt + "th");
        }
    }
    
    public static string ToEnglishOrdinalString(this int eo)
    {
        return (eo.ToString().ToEnglishOrdinalString());
    }
}
