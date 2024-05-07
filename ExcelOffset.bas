Attribute VB_Name = "Module1"
Sub Move_Selection_Right_Column()
'Moves selection one column to the right

  On Error Resume Next
    Selection.Offset(0, 1).Select
  On Error GoTo 0
  
End Sub

Sub Move_Selection_Left_Column()
'Moves selection one column to the left

  On Error Resume Next
    Selection.Offset(0, -1).Select
  On Error GoTo 0

End Sub

Sub Move_Selection_Down_Row()
'Moves selection down one row

  On Error Resume Next
    Selection.Offset(1, 0).Select
  On Error GoTo 0
  
End Sub

Sub Move_Selection_Up_Row()
'Moves selection up one row

  On Error Resume Next
    Selection.Offset(-1, 0).Select
  On Error GoTo 0
  
End Sub
