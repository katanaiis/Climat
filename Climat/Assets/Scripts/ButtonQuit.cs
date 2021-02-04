using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class ButtonQuit : MonoBehaviour
{
    public Canvas canvas;
    //public Button button;

    void Start()
    {
        /*if( canvas == null)
        {
            transform.parent.GetComponent<canvas>();
        }*/
        
    }

    public void Quit()
    {
        foreach(Transform child in canvas.transform)
        {
            //button.enabled = active;
            child.gameObject.SetActive(false);
        }
    }
}
