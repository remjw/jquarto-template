## ---- algorithmengine ---
# enable algorithm env
eng_algo <- function(options) {
  if (!options$eval) {
    return(engine_output(options, options$code, ""))
  }
  
  # wrap in algorithm
  options$fig.env <- "algorithm"
  options$fig.align <- "default"
  options$fig.lp <- "fig:" # alg doesn't work!!
  
  # stuff from knitr
  `%n%` <- function(x, y) if (is.null(x)) y else x
  
  # template
  # H required to work in standalone...
  lines <- r"(\documentclass{standalone}
  %% EXTRA_PREAMBLE_CODE %%
  \usepackage[
  %% ALGO_CLASSOPTION %%
  ]{algorithm2e}
  \begin{document}
  \begin{algorithm}[H]
  %% ALGO_CODE %%
  \end{algorithm}
  \end{document}
  )"
  
  lines <- unlist(strsplit(lines, "\n"))
  
  options$resize.width <- NULL
  options$resize.height <- NULL
  options$resize.command <- NULL
  
  # add class options to template
  lines <- knitr:::insert_template(
    lines, "%% ALGO_CLASSOPTION %%", "linesnumbered,vlined", F
  )
  # insert code into preamble
  lines <- knitr:::insert_template(
    lines, "%% EXTRA_PREAMBLE_CODE %%", options$engine.opts$extra.preamble, F
  )
  
  options$fig.cap <- if (knitr::is_html_output() && !(grepl("(A|a)lgorithm", options$fig.cap))) {
    paste(options$fig.cap, "algorithm")
  } else {
    options$fig.cap
  }
  
  # insert tikz code into the tex template
  s <- knitr:::insert_template(lines, "%% ALGO_CODE %%", options$code)
  xfun::write_utf8(s, texf <- knitr:::wd_tempfile("tikz", ".tex"))
  # on.exit(unlink(texf), add = TRUE)
  
  ext <- tolower(options$fig.ext %n% knitr:::dev2ext(options$dev))
  
  to_svg <- ext == "svg"
  outf <- if (to_svg) tinytex::latexmk(texf, "latex") else tinytex::latexmk(texf)
  
  fig <- knitr:::fig_path(if (to_svg) ".dvi" else ".pdf", options)
  dir.create(dirname(fig), recursive = TRUE, showWarnings = FALSE)
  file.rename(outf, fig)
  
  fig2 <- xfun:::with_ext(fig, ext)
  if (to_svg) {
    # dvisvgm needs to be on the path
    # dvisvgm for windows needs ghostscript bin dir on the path also
    if (Sys.which("dvisvgm") == "") tinytex::tlmgr_install("dvisvgm")
    if (system2("dvisvgm", c(
      options$engine.opts$dvisvgm.opts, "-o", shQuote(fig2), fig
    )) != 0) {
      stop("Failed to compile ", fig, " to ", fig2)
    }
  } else {
    # convert to the desired output-format using magick
    if (ext != "pdf") {
      magick::image_write(do.call(magick::image_convert, c(
        list(magick::image_read_pdf(fig), ext), options$engine.opts$convert.opts
      )), fig2)
    }
  }
  fig <- fig2
  
  options$engine <- "tikz" # pretend to be tikz
  options$fig.num <- 1L
  options$fig.cur <- 1L
  extra <- knitr:::run_hook_plot(fig, options)
  options$engine <- "tex" # for output hooks to use the correct language class
  knitr::engine_output(options, options$code, "", extra)
}

# set engine
knitr::knit_engines$set(algorithm = eng_algo)

# connect dvisvgm to Ghostscript for tikz
# find gs, run: tools:find_gs_cmd()
Sys.setenv(LIBGS = "/usr/local/bin/gs")