# merge_rules.ps1
try {
    $OutFile = "dist\clash_ad_rules.txt"
    $Sources = @(
        "https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Ads-Rule/main/Filters/AWAvenue-Ads-Rule-Clash.yaml",
        "https://raw.githubusercontent.com/REIJI007/AdBlock_Rule_For_Clash/main/adblock_reject.yaml",
        "https://anti-ad.net/clash.yaml"
    )

    # 创建输出目录
    New-Item -ItemType Directory -Force -Path dist -ErrorAction SilentlyContinue

    $domains = @()

    foreach ($url in $Sources) {
        Write-Host "Downloading $url"
        try {
            $content = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop
            foreach ($line in $content.Content.Split("`n")) {
                $line = $line.Trim()
                if ($line -match "^\|\|([^\^\/]+)") {
                    $domains += $matches[1].ToLower()
                }
            }
        } catch {
            Write-Host "⚠️ Failed to download $url. Skipping."
        }
    }

    # 去重
    $domains = $domains | Sort-Object -Unique

    "# Generated on $(Get-Date -Format u)" | Out-File $OutFile
    $domains | ForEach-Object { "DOMAIN-SUFFIX,$_"} | Out-File $OutFile -Append
    Write-Host "✅ Done! Output: $OutFile"

} catch {
    Write-Host "⚠️ Unexpected error: $_"
} finally {
    exit 0  # 保证 workflow 不报错
}
