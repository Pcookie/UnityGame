
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IL3DN_PlayRandomSound : MonoBehaviour
{
    public AudioSource audioSource;
    public AudioClip[] sounds;
    public float minDelay;
    public float maxDelay;
    float currentTime;
    float playTime;
    AudioClip currentSound;

    private void Start()
    {
        SetupSound();
    }

    private void SetupSound()
    {
        currentSound = sounds[Random.Range(0, sounds.Length)];
        playTime = Random.Range(minDelay, maxDelay);
        currentTime = 0;
    }

    private void Update()
    {
        currentTime += Time.deltaTime;
        if(currentTime>playTime)
        {
            SetupSound();
            audioSource.PlayOneShot(currentSound);
        }
    }
}
