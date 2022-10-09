# jquarto-template

### gh

- brew install gh
- gh auth login

- gh repo delete: operation needs the "delete_repo" scope. To request it, run  
`gh auth refresh -h github.com -s delete_repo`

- gh repo delete
- gh repo create <name> --public --add-readme


### From GitHub Repo to RStudio Project

-   RStudio Project

```{r eval=F}
usethis::create_from_github(
  "https://github.com/remjw/jquarto-template.git",
  destdir = "~/Documents/quarto/",
  rstudio=TRUE
)
```

-   renv

```{r eval=F}
renv::init() # from renv.lock file
renv::snapshot()
```

-   .venv

```{bash eval=F}
# create
python3 -m venv .venv
# activate
source .venv/bin/activate
# install
pip install -r requirements.txt
# snapshot
python3 -m pip freeze > requirements.txt
```

-   variables.yml

- Preview & Render

```{bash eval=F}
(.venv) (quarto) $ quarto preview jquarto-template
(.venv) (quarto) $ quarto render jquarto-template
```


