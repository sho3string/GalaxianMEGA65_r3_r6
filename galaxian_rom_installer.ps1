$WorkingDirectory = Get-Location
$length = 47

	cls
	Write-Output " .----------------------."
	Write-Output " |Building Galaxian ROMs|"
	Write-Output " '----------------------'"

	New-Item -ItemType Directory -Path $WorkingDirectory"\arcade" -Force
	New-Item -ItemType Directory -Path $WorkingDirectory"\arcade\galaxian" -Force
	
	Write-Output "Copying Galaxian ROMs"
	# Define the file paths within the folder
	$files = @("$WorkingDirectory\galmidw.u", 
				"$WorkingDirectory\galmidw.v",
				"$WorkingDirectory\galmidw.w",
				"$WorkingDirectory\galmidw.y",
				"$WorkingDirectory\7l",
				"$WorkingDirectory\7l",
				"$WorkingDirectory\7l",
				"$WorkingDirectory\7l",
				"$WorkingDirectory\galmidw.u", 
				"$WorkingDirectory\galmidw.v",
				"$WorkingDirectory\galmidw.w",
				"$WorkingDirectory\galmidw.y",
				"$WorkingDirectory\7l",
				"$WorkingDirectory\7l",
				"$WorkingDirectory\7l",
				"$WorkingDirectory\7l")
				
	# Specify the output file within the folder
	$outputFile = "$WorkingDirectory\arcade\galaxian\mc_roms"
	# Concatenate the files as binary data
	
	[Byte[]]$combinedBytes = @()
	foreach ($file in $files) {
		$combinedBytes += [System.IO.File]::ReadAllBytes($file)
	}
	[System.IO.File]::WriteAllBytes($outputFile, $combinedBytes)
	
	Write-Output "Copying Color Lookup Table"
	Copy-Item -Path $WorkingDirectory\6l.bpr -Destination $WorkingDirectory\arcade\galaxian\clut
	
	
	Write-Output "Copying GFX1 ROMs"
	# Define the file paths within the folder
	$files = @("$WorkingDirectory\1h.bin", 
				"$WorkingDirectory\1h.bin")
				
	# Specify the output file within the folder
	$outputFile = "$WorkingDirectory\arcade\galaxian\h_roms"
	# Concatenate the files as binary data
	
	[Byte[]]$combinedBytes = @()
	foreach ($file in $files) {
		$combinedBytes += [System.IO.File]::ReadAllBytes($file)
	}
	[System.IO.File]::WriteAllBytes($outputFile, $combinedBytes)
	

	# Define the file paths within the folder
	$files = @("$WorkingDirectory\1k.bin", 
				"$WorkingDirectory\1k.bin")
				
	# Specify the output file within the folder
	$outputFile = "$WorkingDirectory\arcade\galaxian\k_roms"
	# Concatenate the files as binary data
	
	[Byte[]]$combinedBytes = @()
	foreach ($file in $files) {
		$combinedBytes += [System.IO.File]::ReadAllBytes($file)
	}
	[System.IO.File]::WriteAllBytes($outputFile, $combinedBytes)
	
	
	Write-Output "Generating blank config file"
	$bytes = New-Object byte[] $length
	for ($i = 0; $i -lt $bytes.Length; $i++) {
	$bytes[$i] = 0xFF
	}
	
	$output_file = Join-Path -Path $WorkingDirectory -ChildPath "arcade\galaxian\galxcfg"
	$output_directory = [System.IO.Path]::GetDirectoryName($output_file)
	[System.IO.File]::WriteAllBytes($output_file,$bytes)

	Write-Output "All done!"