VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Sheet1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Private Sub Btn1_Click()
    Btn1.Enabled = False
    Btn2.Enabled = True
    AutoCapture
End Sub

Private Sub Btn2_Click()
    Btn1.Enabled = True
    Btn2.Enabled = False
    StopCapture
End Sub

Private Sub Btn_Clear_Click()
    Dim ret As Long
    Dim sheetNum As Long
    sheetNum = 1
    
    ' �m�F
    ret = MsgBox("�G�r�f���X�V�[�g���폜���܂���", vbYesNo)
    If (vbNo = ret) Then
        Exit Sub
    End If
    
    ' �V�[�g�N���A
    For Each ws In Worksheets
        If ws.Name = "�G�r�f���X" + CStr(sheetNum) Then
            sheetNum = sheetNum + 1
            Application.DisplayAlerts = False
            ws.Delete
            Application.DisplayAlerts = True
        End If
    Next ws
    Btn2_Click
End Sub