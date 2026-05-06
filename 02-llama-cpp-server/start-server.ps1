# Launch llama-server (via llama-cpp-python) reading models/active.json.
# Windows PowerShell 7+.
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

$active = Get-Content "models/active.json" -Raw | ConvertFrom-Json
$hw     = Get-Content "hardware.json" -Raw | ConvertFrom-Json

$model   = $active.primary_model
$threads = if ($hw.cpu.cores_physical) { [string]$hw.cpu.cores_physical } else { '4' }
$gpu     = if ($env:LAB_N_GPU_LAYERS) { $env:LAB_N_GPU_LAYERS } elseif ($hw.gpu.backends.cpu_only) { '0' } else { '99' }
$ctx     = if ($env:LAB_N_CTX) { $env:LAB_N_CTX } else { '2048' }

if (-not $model) {
    throw "models/active.json missing 'primary_model'. Re-run: python .\00-setup\download-model.py"
}
if (-not (Test-Path -LiteralPath $model)) {
    throw "Model file not found: $model"
}

Write-Host "==> Starting llama-server" -ForegroundColor Cyan
Write-Host "    model     : $model"
Write-Host "    threads   : $threads"
Write-Host "    gpu_layers: $gpu"
Write-Host "    ctx       : $ctx"
Write-Host "    listening : http://0.0.0.0:8080"
Write-Host ""

python -m llama_cpp.server `
    --model "$model" `
    --host 0.0.0.0 --port 8080 `
    --n_threads $threads `
    --n_gpu_layers $gpu `
    --n_ctx $ctx
