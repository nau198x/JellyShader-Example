using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyJellyClickReceiver : MonoBehaviour {

    Renderer modelRenderer; // MeshRendererのComponentをキャッシュする
    float controlTime;

    private void Start()
    {
        modelRenderer = GetComponent<MeshRenderer>();
    }

    private void Update()
    {
        controlTime += Time.deltaTime;
        if (Input.GetMouseButtonDown(0)) controlTime = 0;
        modelRenderer.material.SetFloat("_ControlTime", controlTime);
    }

}