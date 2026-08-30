param(
  [double]$Pad = 0.6,
  [int]$Scenes = 8,
  [string]$Root = $PSScriptRoot,
  [string]$OutFile = "$PSScriptRoot\out\language_and_the_mind_seoul_60s.mp4"
)
# Assembles frames/*.png + audio/*.wav into one mp4 with Ken Burns motion.
$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path (Split-Path $OutFile) | Out-Null
$list = Join-Path $Root "segs\list.txt"
Remove-Item $list -ErrorAction SilentlyContinue
$total = 0.0
for ($i = 1; $i -le $Scenes; $i++) {
  $wav = Join-Path $Root ("audio\scene{0}.wav" -f $i)
  $png = Join-Path $Root ("frames\scene{0}.png" -f $i)
  $dur = [double](ffprobe -v error -show_entries format=duration -of csv=p=0 $wav) + $Pad
  $total += $dur
  $frames = [math]::Ceiling($dur * 30)
  $seg = Join-Path $Root ("segs\seg{0}.mp4" -f $i)
  if ($i % 2 -eq 1) { $zexpr = "min(1+0.0011*on,1.14)" } else { $zexpr = "max(1.14-0.0011*on,1.0)" }
  $vf = "scale=2304:1296,zoompan=z='$zexpr':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=${frames}:s=1920x1080:fps=30,format=yuv420p"
  $af = "apad=whole_dur=${dur},aresample=48000"
  ffmpeg -y -loglevel error -loop 1 -i $png -i $wav -filter_complex "[0:v]${vf}[v];[1:a]${af}[a]" -map "[v]" -map "[a]" -t $dur -r 30 -c:v libx264 -preset medium -crf 19 -c:a aac -b:a 160k $seg
  if ($LASTEXITCODE -ne 0) { throw "ffmpeg failed on scene $i" }
  Add-Content $list ("file '{0}'" -f $seg.Replace('\','/'))
}
Write-Output ("planned_total_seconds=" + [math]::Round($total, 2))
ffmpeg -y -loglevel error -f concat -safe 0 -i $list -c copy $OutFile
if ($LASTEXITCODE -ne 0) { throw "concat failed" }
$probe = ffprobe -v error -show_entries format=duration,size -of default=nw=1 $OutFile
Write-Output ("FINAL " + $OutFile)
Write-Output $probe
