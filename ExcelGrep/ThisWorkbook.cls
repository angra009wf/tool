VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThisWorkbook"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit
 
Const STR_GREP_SHEET_NAME As String = "Grep"
Public sMsgString As String
Public sFilePathRoot As String
Public sKeyWord As String
Public lcnt As Long
 
 
'Grep���C���֐�
Public Sub grepMain()
    Dim bErrFlag As Boolean
    bErrFlag = False
    
    sFilePathRoot = ThisWorkbook.Sheets(STR_GREP_SHEET_NAME).Cells(4, 3).Value
    sKeyWord = ThisWorkbook.Sheets(STR_GREP_SHEET_NAME).Cells(5, 3).Value
 
    '�G���[�`�F�b�N
    bErrFlag = inputCheck
 
    If bErrFlag = False Then
 
        '�`�����������I�t
        Application.ScreenUpdating = False
    
        '�ꗗ���N���A
        Call clearCells
    
        If Right(sFilePathRoot, 1) <> "\" Then
            sFilePathRoot = sFilePathRoot & "\"
        
        End If
    
        lcnt = 8
        
        'Excel�t�@�C����Grep
        Call openExcelFiles(sFilePathRoot)
        
        '�r��������
        Call addLines
        
        '�`����I��
        Application.ScreenUpdating = True
        
        sMsgString = "Grep���������܂����I�I"
    
    End If
    
    '���b�Z�[�W�o��
    MsgBox sMsgString
    
End Sub
 
 
'���͓��e�`�F�b�N
Private Function inputCheck() As Boolean
    inputCheck = False
    If sKeyWord = "" Then
        sMsgString = "�L�[���[�h�����͂���Ă��܂���"
        inputCheck = True
    End If
End Function
 
 
'�w�肵���t�H���_���̃G�N�Z���t�@�C����S����
Private Sub openExcelFiles(ByVal sFilePath As String)
    
    Dim lSheetNo As Long
    Dim sTmpPath As String
    Dim oFSO As Object
    
    If Right(sFilePath, 1) <> "\" Then
        sFilePath = sFilePath & "\"
    End If
    
    'Dir�Ō��������t�@�C�������擾
    sTmpPath = Dir(sFilePath & "*.xlsx")
    
    '�����t�H���_���ŃG�N�Z���t�@�C������������茟��
    Do While sTmpPath <> ""
        
        If Left(sTmpPath, 2) = "~$" Then
            GoTo CONTINUE
        End If
        '�ǂݎ���p�A�X�V�Ȃ��ŊJ��
        Dim wb As Workbook
        Workbooks.Open sFilePath & sTmpPath, UpdateLinks:=0, ReadOnly:=1
        Set wb = ActiveWorkbook
        Debug.Print "�t�@�C�����F" & wb.Name
        If wb.Name = "RKKCS_INFOPUB-449_�P�̃e�X�g�d�l���^���я�.xlsx" Then
            Debug.Print ""
        End If
            
            '�S�V�[�g���[�v
            For lSheetNo = 1 To wb.Worksheets.Count
            
                '�V�[�g����Grep
                Call grepExcelSheet(sFilePath, sTmpPath, lSheetNo)
                
            Next lSheetNo
        
        Application.DisplayAlerts = False
        Workbooks(sTmpPath).Close
        Application.DisplayAlerts = True
        
CONTINUE:
        sTmpPath = Dir()
    Loop
    
    '���̊֐����g���Ăяo���āA�T�u�t�H���_���ċA�I�Ɍ���
    With CreateObject("Scripting.FileSystemObject")
        For Each oFSO In .GetFolder(sFilePath).SubFolders
            Call openExcelFiles(oFSO.Path)
        Next oFSO
    End With
    
    Set oFSO = Nothing
 
End Sub
 
'Excel�̃V�[�g����Grep
Private Sub grepExcelSheet(ByVal sFilePath As String, ByVal sTmpPath As String, ByVal lSheetNo As Long)
 
    Dim lCellRow As Long, lCellCol As Long
    Dim rFoundCell As Range, rFoundFirstCell As Range
    Dim rEndRange As Range
    Dim rTmpFoundCell As Range
    Dim sTmpSheetName As String
    
 
    With Workbooks(sTmpPath).Sheets(lSheetNo)
        Debug.Print "�V�[�g���F" & .Name
        '�V�[�g��1���ڂɌ��������Z�����擾
        Set rTmpFoundCell = .Cells.Find(What:=sKeyWord, LookAt:=xlPart)
        
        '������Ȃ�������֐��𔲂���
        If rTmpFoundCell Is Nothing Then Exit Sub
        
        '�V�[�g�����擾
        sTmpSheetName = .Name
        
        '�ŏ��Ɍ��������Z������ێ�
        Set rFoundFirstCell = rTmpFoundCell
        
        Do
        
            '���������Z���̏����ꗗ�ɋL��
            Call outputCellInfo(sTmpPath, sFilePath, sTmpSheetName, rTmpFoundCell)
        
            '�V�[�g��2���ڈȍ~�Ɉ�v�������
            Set rTmpFoundCell = .Cells.FindNext(rTmpFoundCell)
        
            If rTmpFoundCell Is Nothing Then
                Exit Do
            End If
        '���������Z�����ŏ��Ɍ��������Z���ƈقȂ�ԃ��[�v
        Loop While rTmpFoundCell <> rFoundFirstCell
    
    End With
 
End Sub
 
 
'�L�[���[�h���܂ރZ���̏����A�E�g�v�b�g
Private Sub outputCellInfo(ByVal sTmpPath As String, ByVal sFilePath As String, ByVal sTmpSheetName As String, _
                                                                            ByVal rFoundCell As Range)
                                                                            
    With ThisWorkbook.Sheets(STR_GREP_SHEET_NAME)
        
        'No
        .Cells(lcnt, 2).Value = lcnt - 7
        
        '�p�X
        .Cells(lcnt, 3).Value = sFilePath
        
        '�t�@�C����
        .Cells(lcnt, 4).Value = sTmpPath
        
        '�V�[�g��
        .Cells(lcnt, 5).Value = sTmpSheetName
        
        '�Z���̈ʒu
        .Cells(lcnt, 6).Value = convertRange(rFoundCell.Column) & rFoundCell.Row
        
        '�L�[���[�h���܂ރZ���̓��e
        .Cells(lcnt, 7).Value = rFoundCell.Value
        
    End With
 
    '���̍s�ɌJ��グ��
    lcnt = lcnt + 1
 
End Sub
 
 
'�Z���̈ʒu��ϊ�
Private Function convertRange(ByVal lCol As Long) As String
    convertRange = ""
    
    Dim lTmpCol As Long
    Dim lBuf As Long
    Dim sAsc As Long
    sAsc = 64
    
    If Len(lCol) = 0 Then Exit Function
    
    lTmpCol = lCol
    
    '1���ڂ�ϊ�
    lBuf = sAsc + lTmpCol Mod 26
        
    convertRange = Chr(lBuf)
    
    lTmpCol = lTmpCol \ 26
    
    '2���ڂ�ϊ�
    If lTmpCol Mod 26 >= 1 Then
        
        lBuf = sAsc + lTmpCol Mod 26
        convertRange = Chr(lBuf) & convertRange
        
    End If
    
    '3���ڂ�ϊ�
    If lTmpCol \ 26 >= 1 Then
    
        lBuf = sAsc + lTmpCol \ 26
        convertRange = Chr(lBuf) & convertRange
        
    End If
 
End Function
 
 
'�r��������
Private Sub addLines()
    
    Dim lRow As Long
    
    '8�s�ڈȍ~��I��
    lRow = ThisWorkbook.Sheets(STR_GREP_SHEET_NAME).Cells(Rows.Count, 2).End(xlUp).Row
    
    '0���̏ꍇ�͌r���������Ȃ�
    If lRow < 8 Then Exit Sub
    
    Range("B8:G" & lRow).Select
    
    '�ŏ��ɒʏ�̌r��������
    With Selection.Borders()
    
        .LineStyle = xlContinuous
        .Weight = xlThin
    
    End With
    
    '�����̉������̌r�������_���ɂ���
    With Selection.Borders(xlInsideHorizontal)
    
        .LineStyle = xlContinuous
        .Weight = xlHairline
    
    End With
    
    Range("A1").Select
    
End Sub
 
'�Z�����N���A
Private Sub clearCells()
 
    '7�s�ȉ��Ȃ�N���A���Ȃ�
    If ActiveCell.SpecialCells(xlLastCell).Row < 8 Then
        Exit Sub
    End If
 
    '8�s�ڈȍ~���N���A
    Range("B8", ActiveCell.SpecialCells(xlLastCell)).Select
    Selection.Borders().LineStyle = xlLineStyleNone
    Selection.ClearFormats
    Selection.ClearContents
    Range("A1").Select
        
End Sub
