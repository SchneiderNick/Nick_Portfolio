param([string[]]$Test=@())

Write-Host $Test.Count

Foreach($Val in $Test)
{
	Write-Host $Val
}
