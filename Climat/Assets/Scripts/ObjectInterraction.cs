using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ObjectInterraction : MonoBehaviour
{
    public GameObject image;
    //public GameObject button;

    //[SerializeField] private Image customImage;


    // Start is called before the first frame update

    // Update is called once per frame
    void OnMouseDown()
    {
        Debug.Log("click sur " + this.gameObject.name); //affiche png sur caméra 
        if (image.activeSelf)
        {
            image.SetActive(false);
            //button.SetActive(false);
        }
        else
        {
            image.SetActive(true);
            //button.SetActive(true);
        }
    }
}
