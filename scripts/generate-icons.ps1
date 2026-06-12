# Generates public/icon-192.png and public/icon-512.png for the PWA manifest.
# Matches app/icon.svg: coral background (full bleed, maskable safe),
# gold circle crest with a cream ring and "PP" wordmark in ink.
Add-Type -AssemblyName System.Drawing

function New-Icon([int]$size, [string]$outPath) {
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

    # Brand colors
    $coral = [System.Drawing.Color]::FromArgb(255, 255, 107, 107)  # #FF6B6B
    $gold  = [System.Drawing.Color]::FromArgb(255, 244, 185, 66)   # #F4B942
    $cream = [System.Drawing.Color]::FromArgb(255, 255, 248, 240)  # #FFF8F0
    $ink   = [System.Drawing.Color]::FromArgb(255, 45, 49, 66)     # #2D3142

    # Background: full-bleed coral so maskable crops stay clean
    $g.Clear($coral)

    # Gold circle crest, centered (within the maskable safe zone)
    $crestR = $size * 0.3125  # 20/64 of the SVG
    $cx = $size / 2.0
    $cy = $size / 2.0
    $goldBrush = New-Object System.Drawing.SolidBrush($gold)
    $g.FillEllipse($goldBrush, [float]($cx - $crestR), [float]($cy - $crestR), [float](2 * $crestR), [float](2 * $crestR))

    # Cream inner ring
    $ringR = $size * 0.265  # 17/64
    $ringPen = New-Object System.Drawing.Pen($cream, [float]($size * 0.0235))
    $g.DrawEllipse($ringPen, [float]($cx - $ringR), [float]($cy - $ringR), [float](2 * $ringR), [float](2 * $ringR))

    # "PP" wordmark in ink, centered in the crest
    $fontSize = [float]($size * 0.22)
    $font = $null
    foreach ($name in @('Arial Rounded MT Bold', 'Arial')) {
        try {
            $font = New-Object System.Drawing.Font($name, $fontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
            if ($font.Name -eq $name) { break }
        } catch {}
    }
    $inkBrush = New-Object System.Drawing.SolidBrush($ink)
    $fmt = New-Object System.Drawing.StringFormat
    $fmt.Alignment = [System.Drawing.StringAlignment]::Center
    $fmt.LineAlignment = [System.Drawing.StringAlignment]::Center
    $rect = New-Object System.Drawing.RectangleF(0, 0, $size, $size)
    $g.DrawString('PP', $font, $inkBrush, $rect, $fmt)

    $g.Dispose()
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Output "Wrote $outPath"
}

$publicDir = Join-Path $PSScriptRoot "..\public"
New-Icon 192 (Join-Path $publicDir "icon-192.png")
New-Icon 512 (Join-Path $publicDir "icon-512.png")
