dir_name <- paste0(R.version$major, ".", strsplit(R.version$minor, "\\.")[[1]][1])
.libPaths(c(normalizePath(file.path("~", "R", "win-library", dir_name), mustWork = FALSE), .libPaths()))

pkgs <- c("curl", "remotes")
pkgs <- pkgs[!(pkgs %in% installed.packages()[, 1])]

if (length(pkgs) > 0) {
    install.packages(pkgs, repos = "https://cloud.r-project.org/")
}
remotes::install_cran(c("rlang", "vctrs", "desc"))
tempdir <- tempfile()
dir.create(tempdir, recursive = TRUE)
curl::curl_download("https://raw.githubusercontent.com/extendr/rextendr/main/DESCRIPTION", file.path(tempdir, "DESCRIPTION"))

deps <- desc::desc_get_deps(file.path(tempdir, "DESCRIPTION"))
deps <- deps[deps$type != "Depends",]
cat("{rextendr} requires the following packages:\n")
print(deps)
remotes::install_cran(deps$package)
remotes::install_github("extendr/rextendr")

cat("Everything is set up!\n")
cat("Try out {rextendr} by copy-pasting this code fragment into your pwsh:\n\n")
cat('\tRscript.exe -e "rextendr::rust_function(\'fn rust_add(a:i32,b:i32) -> i32 { a + b }\'); rust_add(10, 42)"\n')