using UnityEngine;
using UnityEngine.InputSystem;

public class Player : MonoBehaviour
{
    [SerializeField] Material heatVision;

    [SerializeField] bool viewEnemys = false;

    void Start()
    {

    }

    void Update()
    {
        
    }

    public void Interaction(InputAction.CallbackContext value)
    {
        if(!value.performed)
        {
            return;
        }

        Debug.Log("Trocou");

        if(value.ReadValue<float>() >= 0.5f)
        {
            if (viewEnemys)
            {
                viewEnemys = false;

                heatVision.SetFloat("_View", 1);
            }
            else
            {
                viewEnemys = true;

                heatVision.SetFloat("_View", 0);
            }
        }
    }
}
