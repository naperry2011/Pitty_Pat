# Generates public/og-image.png (1200x630) for Open Graph / social sharing.
# Coral background, three fanned white cards center-left with pip hints,
# "Pitty Pat!" wordmark and "Play free online" subline on the right.
Add-Type -AssemblyName System.Drawing

$w = 1200
$h = 630
$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

# Brand colors
$coral     = [System.Drawing.Color]::FromArgb(255, 255, 107, 107)  # #FF6B6B
$coralDeep = [System.Drawing.Color]::FromArgb(255, 232, 72, 85)    # #E84855
$white     = [System.Drawing.Color]::White
$ink       = [System.Drawing.Color]::FromArgb(255, 45, 49, 66)     # #2D3142
$gold      = [System.Drawing.Color]::FromArgb(255, 244, 185, 66)   # #F4B942

# Background: coral with a subtle diagonal deepen toward the bottom-right
$bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point(0, 0)),
    (New-Object System.Drawing.Point($w, $h)),
    $coral, $coralDeep)
$g.FillRectangle($bgBrush, 0, 0, $w, $h)

function New-RoundedRectPath([float]$x, [float]$y, [float]$rw, [float]$rh, [float]$r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $rw - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $rw - $d, $y + $rh - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $rh - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

function Get-Font([float]$sizePx, [System.Drawing.FontStyle]$style) {
    foreach ($name in @('Arial Rounded MT Bold', 'Arial')) {
        try {
            $f = New-Object System.Drawing.Font($name, $sizePx, $style, [System.Drawing.GraphicsUnit]::Pixel)
            if ($f.Name -eq $name) { return $f }
        } catch {}
    }
    return New-Object System.Drawing.Font('Arial', $sizePx, $style, [System.Drawing.GraphicsUnit]::Pixel)
}

$whiteBrush = New-Object System.Drawing.SolidBrush($white)
$inkBrush = New-Object System.Drawing.SolidBrush($ink)
$redBrush = New-Object System.Drawing.SolidBrush($coralDeep)
$shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(60, 45, 49, 66))
$centerFmt = New-Object System.Drawing.StringFormat
$centerFmt.Alignment = [System.Drawing.StringAlignment]::Center
$centerFmt.LineAlignment = [System.Drawing.StringAlignment]::Center

# Three fanned cards, center-left. Each card: white rounded rect + one big pip glyph.
$cardW = 210.0
$cardH = 315.0
$fanCx = 330.0
$fanCy = 330.0
$cornerFont = Get-Font 64 ([System.Drawing.FontStyle]::Bold)
$centerPipFont = Get-Font 110 ([System.Drawing.FontStyle]::Bold)

$cards = @(
    @{ angle = -22; xoff = -70; glyph = ([char]0x2660); brush = $inkBrush },   # spade
    @{ angle = 0;   xoff = 0;   glyph = ([char]0x2665); brush = $redBrush },   # heart
    @{ angle = 22;  xoff = 70;  glyph = ([char]0x2666); brush = $redBrush }    # diamond
)

foreach ($card in $cards) {
    $state = $g.Save()
    $g.TranslateTransform([float]($fanCx + $card.xoff), [float]($fanCy + $cardH / 2 - 20))
    $g.RotateTransform([float]$card.angle)
    $g.TranslateTransform([float](-$cardW / 2), [float](-$cardH + 20))

    # Soft drop shadow, then the card
    $shadowPath = New-RoundedRectPath 8 12 $cardW $cardH 22
    $g.FillPath($shadowBrush, $shadowPath)
    $cardPath = New-RoundedRectPath 0 0 $cardW $cardH 22
    $g.FillPath($whiteBrush, $cardPath)

    # Corner pip (top-left, stays visible when the cards overlap)
    $cornerRect = New-Object System.Drawing.RectangleF(14, 12, 84, 84)
    $g.DrawString([string]$card.glyph, $cornerFont, $card.brush, $cornerRect, $centerFmt)

    # Big centered pip
    $pipRect = New-Object System.Drawing.RectangleF(0, 40, $cardW, ($cardH - 40))
    $g.DrawString([string]$card.glyph, $centerPipFont, $card.brush, $pipRect, $centerFmt)

    $g.Restore($state)
}

# Wordmark and subline on the right
$titleFont = Get-Font 110 ([System.Drawing.FontStyle]::Bold)
$subFont = Get-Font 44 ([System.Drawing.FontStyle]::Regular)
$textShadow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(70, 45, 49, 66))

$titleRect = New-Object System.Drawing.RectangleF(600, 200, 580, 160)
$titleShadowRect = New-Object System.Drawing.RectangleF(604, 206, 580, 160)
$g.DrawString('Pitty Pat!', $titleFont, $textShadow, $titleShadowRect, $centerFmt)
$g.DrawString('Pitty Pat!', $titleFont, $whiteBrush, $titleRect, $centerFmt)

$goldBrush = New-Object System.Drawing.SolidBrush($gold)
$subRect = New-Object System.Drawing.RectangleF(600, 370, 580, 70)
$g.DrawString('Play free online', $subFont, $goldBrush, $subRect, $centerFmt)

$g.Dispose()
$outPath = Join-Path $PSScriptRoot "..\public\og-image.png"
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output "Wrote $outPath"
