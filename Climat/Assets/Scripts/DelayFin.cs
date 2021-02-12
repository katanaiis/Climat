using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class DelayFin : MonoBehaviour
{
    float currentTime = 0f;
    float startingTime = 5f;

    public string sceneName;

    // Start is called before the first frame update
    void Start()
    {
        currentTime = startingTime;
    }

    // Update is called once per frame
    void Update()
    {
        currentTime -= 1 * Time.deltaTime;
        //print(currentTime);

        if (currentTime <= 0f)
        {
            SceneManager.LoadScene(sceneName);
        }
    }
}
