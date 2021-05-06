install.packages(c("curl", "remotes"))
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
cat('\tRscript.exe -e "rextendr::rust_function(\\`"fn hello_world() -> String {\\\\\\\`"Hello world!\\\\\\\`".into()} \\`") ; hello_world()"\n')