$SCCM_File = "####################"
$List_Of_Computers = "####################"
"Computer Names" > $List_Of_Computers
Foreach($Computer in (Get-Content $SCCM_File))
{
	try {
		
		$Temp = Get-ADComputer $Computer
		
	}
	
	Catch {
		
		$Computer >> $List_Of_Computers
		
	}
	
	
}

