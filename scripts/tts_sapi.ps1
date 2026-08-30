param(
  [int]$Rate = 0,
  [string]$ScriptPath = "$PSScriptRoot\script.json",
  [string]$OutDir = "$PSScriptRoot\audio"
)
# Fully-local TTS using Windows SAPI (no network, no API keys).
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$scenes = Get-Content $ScriptPath -Raw | ConvertFrom-Json
Add-Type -AssemblyName System.Speech
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$en = $synth.GetInstalledVoices() | Where-Object { $_.VoiceInfo.Culture.Name -like 'en-*' } | Select-Object -First 1
if ($en) { $synth.SelectVoice($en.VoiceInfo.Name) }
$synth.Rate = $Rate
Write-Output ("voice=" + $synth.Voice.Name + " rate=" + $Rate)
foreach ($s in $scenes) {
  $out = Join-Path $OutDir ("scene{0}.wav" -f $s.id)
  $synth.SetOutputToWaveFile($out)
  $synth.Speak($s.narration) | Out-Null
  $synth.SetOutputToNull()
  Write-Output ("wrote " + $out)
}
$synth.Dispose()
