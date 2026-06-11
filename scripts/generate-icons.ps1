# Generates public/icon-192.png and public/icon-512.png for the PWA manifest.
# Coral full-bleed background (maskable safe), white rounded card, red heart.
Add-Type -AssemblyName System.Drawing

function New-Icon([int]$size, [string]$outPath) {
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

    # Background: theme coral, full bleed so maskable crops stay clean
    $coral = [System.Drawing.Color]::FromArgb(255, 255, 107, 107)
    $g.Clear($coral)

    # White rounded card, centered, portrait ratio
    $cardW = [int]($size * 0.46)
    $cardH = [int]($size * 0.62)
    $cardX = [int](($size - $cardW) / 2)
    $cardY = [int](($size - $cardH) / 2)
    $radius = [int]($size * 0.06)

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $radius * 2
    $path.AddArc($cardX, $cardY, $d, $d, 180, 90)
    $path.AddArc($cardX + $cardW - $d, $cardY, $d, $d, 270, 90)
    $path.AddArc($cardX + $cardW - $d, $cardY + $cardH - $d, $d, $d, 0, 90)
    $path.AddArc($cardX, $cardY + $cardH - $d, $d, $d, 90, 90)
    $path.CloseFigure()

    $white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.FillPath($white, $path)

    # Red heart centered on the card: two circles and a point
    $heartW = [int]($cardW * 0.62)
    $cx = $size / 2.0
    $cy = $size / 2.0 - ($heartW * 0.08)
    $r = $heartW / 4.0
    $red = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 229, 57, 53))

    $g.FillEllipse($red, [float]($cx - 2 * $r), [float]($cy - $r), [float](2 * $r), [float](2 * $r))
    $g.FillEllipse($red, [float]$cx, [float]($cy - $r), [float](2 * $r), [float](2 * $r))
    $pts = @(
        (New-Object System.Drawing.PointF([float]($cx - 2 * $r), [float]$cy)),
        (New-Object System.Drawing.PointF([float]($cx + 2 * $r), [float]$cy)),
        (New-Object System.Drawing.PointF([float]$cx, [float]($cy + 2.2 * $r)))
    )
    $g.FillPolygon($red, $pts)

    $g.Dispose()
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Output "Wrote $outPath"
}

$publicDir = Join-Path $PSScriptRoot "..\public"
New-Icon 192 (Join-Path $publicDir "icon-192.png")
New-Icon 512 (Join-Path $publicDir "icon-512.png")
