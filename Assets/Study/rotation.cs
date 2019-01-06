using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class rotation : MonoBehaviour {

    public float f = 0.0f;
    public float speed = 45.0f;
    public Vector3 v = Vector3.zero;

    void FixedUpdate () {
        //if (f < 90.0f)
        //{
            v += new Vector3(1, 1, 1) * Time.deltaTime * speed;
            transform.transform.eulerAngles = v;
            //f += Time.deltaTime * speed;
        //}
    }
}
