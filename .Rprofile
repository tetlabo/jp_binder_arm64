library(utils)
if (Sys.info()[["sysname"]] == "Darwin") {
    options(repos = c(CRAN = "https://p3m.dev/cran/2026-02-01"))
} else if (Sys.info()[["sysname"]] == "Linux") {
    options(repos = c(CRAN = "https://p3m.dev/cran/__linux__/noble/latest"))
}

if (interactive()) {
    later::later(function() {
        if (rstudioapi::isAvailable()) {
          rstudioapi::jobRunScript("/home/rstudio/bin/keepconnect.R", name = "keepconnect")
        }
    }, delay = 5)  # 5秒後に実行（必要なら適宜調整）
}
