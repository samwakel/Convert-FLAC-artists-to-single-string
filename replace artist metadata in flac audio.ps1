# Ensure the directory contains FLAC files
$flacFiles = Get-ChildItem -Filter "*.flac" -File

# Loop through each FLAC file
foreach ($file in $flacFiles) {
    # Get all lines of the artist metadata, this should be multiple lines if there are multiple artists
    $artistLines = & "metaflac" "--show-tag=ARTIST" "$file"
    
    # If there are any artist lines
    if ($artistLines) {
        # Split the output into individual artist lines by line breaks
        $artistValues = $artistLines -split "`r`n" | ForEach-Object { $_ -replace '^ARTIST=', '' }
        
        # Join the artist lines with commas, ensuring they are combined properly
        $newArtistValue = $artistValues -join '; '

        # If there was a change, update the metadata
        if ($newArtistValue -ne ($artistLines -join '; ')) {
            Write-Host "Updating artist for '$file' to '$newArtistValue'"
            & "metaflac" "--remove-tag=ARTIST" "$file"
            & "metaflac" "--set-tag=ARTIST=$newArtistValue" "$file"
        }
    }
}

Write-Host "Metadata update complete."
