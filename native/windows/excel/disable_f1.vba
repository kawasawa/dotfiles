Option Explicit

Sub Auto_Open()
    Application.OnKey "{F1}", "Perform_F2"
End Sub

Sub Perform_F2()
    SendKeys ("{F2}")
End Sub