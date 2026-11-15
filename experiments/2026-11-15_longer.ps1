# E40c: E40b (v12 set + 444 ChoCo / recovered Billboard songs, Bollywood share pinned at 52%) with a
# longer schedule, 140 epochs instead of 80, so each song gets about as many passes as in v12.
# Tests whether E40/E40b's Bollywood cost was undertraining rather than data competition.
$ErrorActionPreference = 'Continue'
function Log($m) { "=== $m $(Get-Date -Format HH:mm:ss)" | Out-File -Append -Encoding utf8 data/logs/batch.log; Write-Output "=== $m" }
$name = 'e40c_long140'
Log $name
& uv run --no-sync chordstream train --init models/latest --lr 3e-4 --epochs 140 --crops 2000 --workers 0 --batch-size 8 `
    --transition-weight 3 --eval-every 10 --vocab extended --label-delay 3 --cache data/cache_ext_bolly3x2_choco `
    --context 800 --random-eq 0.5 --bass-dropout 0.3 --share bollytrain=0.52 --out "models/$name" 2>&1 | Where-Object { $_ -notmatch 'Warning' } | Tee-Object -FilePath "data/logs/$name.log"
Log "$name eval"
uv run --no-sync python experiments/hmm55.py "models/$name"
uv run --no-sync python experiments/analysis_bollywood.py --v3 "models/${name}_h5p2" 2>&1 | Where-Object { $_ -match 'aligned' } | Tee-Object -FilePath "data/logs/${name}_eval.log"
uv run --no-sync python experiments/analysis_bass.py "models/${name}_h5p2" 2>&1 | Where-Object { $_ -match 'Billboard|Bollywood' } | Tee-Object -Append -FilePath "data/logs/${name}_eval.log"
uv run --no-sync python experiments/analysis_raw_flicker.py "models/${name}_h5p2" 2>&1 | Where-Object { $_ -notmatch 'Warning' } | Tee-Object -Append -FilePath "data/logs/${name}_eval.log"
Log "$name done"
