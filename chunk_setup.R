#```{r setup, echo=FALSE, message=FALSE, warning=FALSE}

#tinytex::install_tinytex()
#getOption("encoding")
#rmarkdown::pandoc_version()
#xfun::pkg_load2(c("htmltools", "mime"))

## ---- setup --------
library(reticulate)
#use_condaenv(condaenv = 'iris')#'waterlily')
#Sys.setenv(RETICULATE_PYTHON="H:\\Drive_E\\CSCI-C442\\bookdown-C442-2021\\.venv\\Scripts")
library(knitr)
library(svglite)
library(gt)
library(kableExtra)
library(tidyverse)
library(tsibble)
library(XML)
library(captioner)
figs <- captioner(prefix="Figure")
tbls <- captioner(prefix="Table")
library(RMySQL)
library(DBI)

library(DiagrammeRsvg)  # for conversion to svg
library(rsvg)  # for saving svg

xfun::pkg_load2(c("htmltools", "mime")) #embed files in HTML

knitr::opts_chunk$set(
  attr.source = c('.numberLines'),
  comment = '',
  class.source="numberLines"
)

knitr::opts_chunk$set(
  class.output = "output",
  engine.path = list(dot = ifelse(
    Sys.info()[['sysname']]=='Windows',
    'D:\\graphviz\\release\\bin\\dot.exe',
    '/usr/local/Cellar/graphviz/2.50.0/bin/dot'))
)

knitr::knit_engines$set(html = function(options) {
  # the source code is in options$code; just do
  # whatever you want with it
})



# knitr::knit_hooks$set(formatSQL = function(before, options, envir) {
#
#   #if (!before && opts_current$get("eval")!="FALSE" && opts_current$get("engine")=="sql") {
#
#   if (!before && options$eval!="FALSE" && options$engine=="sql"){
#
#     sqlData <- get(x = opts_current$get("output.var"))
#
#     if (!is.null(sqlData)) {
#
#       max.print <- min(nrow(sqlData), opts_current$get("max.print"))
#
#       myxtable <- do.call(
#         xtable::xtable,
#         c(list(x = sqlData%>%as.tibble(.,.name_repair="unique")%>%slice(1:max.print)),
#              #sqlData[1:max.print, ,drop = FALSE]),
#           opts_current$get("xtable.args")
#           )
#         )
#
#       df <- sqlData %>% as.tibble(., .name_repair="unique")
#
#      myoutput <- capture.output(
#         do.call(knitr::kable, c(list(x=df, format='html'))),
#         file = 'out_html.txt'
#       )
#      print(myoutput)
#
# #      capture.output(
# #        myoutput <- do.call(knitr::kable, c(list(x=sqlData%>%as.tibble(.,.name_repair="unique"),format='html'))),
# #        file='test.txt'
# #      )
#
# #      capture.output(myoutput <-do.call(xtable::print.xtable, c(list(x = myxtable, file = "test.txt"), opts_current$get("print.xtable.args"))))
#
#       return(asis_output(paste(
#         "<div>",
#         myoutput,
#         "</div>")))
#       }}
#
#   return()
# })
#
# knitr::opts_chunk$set(
#   formatSQL = TRUE, output.var = "formatSQL_result"
#   #sql.max.print = 12 #, sql.paged.print = TRUE,
#   #sql.pages.print = 3
# )


## ---- connect-db --------
cons <- dbListConnections(dbDriver( drv = "MySQL"))
#cons %>% map(dbDisconnect)

if (!is.null(cons)) {
  for (c in cons) {
    dbDisconnect(c)
  }
}

ret <- lapply(dbListConnections(MySQL()), dbDisconnect)

library(yaml)
config = yaml.load_file("_variables.yml")

mysqluser <- config$mysql$user
mysqlpw <- config$mysql$password
mysqlhost <- config$mysql$host
mysqlport <- config$mysql$port

# select host,user from mysql.user;
# ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'apple';
codd <- dbConnect(RMySQL::MySQL(),dbname='cape_codd',username=mysqluser,password=mysqlpw, host='127.0.0.1',port=3306)

jsea <- dbConnect(RMySQL::MySQL(),dbname='jsea',username=mysqluser,password=mysqlpw, host='127.0.0.1',port=3306)

test_db <- dbConnect(RMySQL::MySQL(),dbname='test_db',username=mysqluser,password=mysqlpw, host='127.0.0.1',port=3306)

flight <- dbConnect(RMySQL::MySQL(),dbname='flight',username=mysqluser,password=mysqlpw, host='127.0.0.1',port=3306)

flight2 <- dbConnect(RMySQL::MySQL(),dbname='flight2',username=mysqluser,password=mysqlpw, host='127.0.0.1',port=3306)

wesay <- dbConnect(RMySQL::MySQL(),dbname='wesay',username=mysqluser,password=mysqlpw, host='127.0.0.1',port=3306)

vrg <- dbConnect(RMySQL::MySQL(),dbname='vrg',username=mysqluser,password=mysqlpw, host='127.0.0.1',port=3306)

knitr::opts_chunk$set(connection = "codd")


save(codd, jsea, test_db, flight, flight2, wesay, vrg, file = "dbobjs.Rdata")

