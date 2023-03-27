## How to

### Add an article

article_slug <- "about-prototyping-shiny-apps"
dir.create(
  file.path("news", article_slug)
)
file.create(
  file.path("news", article_slug, "index.qmd")
)
write(
  sprintf(
   '---
title: "About prototyping shiny apps"
author: colin
date: "%s"
---', Sys.Date()
  ),
  file.path("news", article_slug, "index.qmd")
)
file.edit(file.path("news", article_slug, "index.qmd"))
### Add a package

#### Render all packages

pkgs <- yaml::read_yaml("packages/packages.yaml")


for (pak in names(pkgs$package)) {
  if (!file.exists(sprintf("packages/%s/", pak))){
    dir.create(
      sprintf("packages/%s/", pak)
    )
  }
  whisker::whisker.render(
    template = readLines("script/empty_package.whisk"),
    data = list(
      pkg = pak,
      title = pkgs$package[[pak]]$title,
      github = pkgs$package[[pak]]$repo,
      description = pkgs$package[[pak]]$description,
      lifecycle = pkgs$package[[pak]]$lifecycle
    )
  ) |> write(
    sprintf("packages/%s/index.qmd", pak)
  )
}

#### Render the package index page

whisker::whisker.render(
  template = readLines("script/empty_package_index.whisk"),
  data = list(
    content ={
     names(pkgs$package) |>
       purrr::map(
        ~ sprintf(
          "|%s|%s|%s|%s|%s|%s|%s|",
          .x,
          htmltools::tags$img(
            src =  sprintf('https://lifecycle.r-lib.org/articles/figures/lifecycle-%s.svg', pkgs$package[[.x]]$lifecycle)
          ) |> as.character(),
          htmltools::tags$a(
            href = sprintf("https://CRAN.R-project.org/package=%s", .x),
            htmltools::tags$img(
              src = sprintf("https://www.r-pkg.org/badges/version/%s", .x)
            )
          ) |> as.character() |> gsub("\n", "", x = _),
          htmltools::tags$a(
            href = sprintf("https://cranlogs.r-pkg.org/downloads/total/last-month/%s", .x),
            htmltools::tags$img(
              src = sprintf("https://cranlogs.r-pkg.org/badges/%s", .x)
            )
          ) |> as.character() |> gsub("\n", "", x = _),
          htmltools::tags$a(
            href = sprintf("%s/actions", pkgs$package[[.x]]$repo),
            htmltools::tags$img(
              src = sprintf("%s/workflows/R-CMD-check/badge.svg", pkgs$package[[.x]]$repo),
              alt = "R-CMD-check"
            )
          ) |>
            as.character() |>
            gsub("\n", "", x = _),
            sprintf(
              '<a class="github-button" href="%s" data-icon="octicon-star" data-show-count="true" aria-label="Star this on GitHub">Stars</a>',
              pkgs$package[[.x]]$repo
            ) |> as.character(),
            sprintf(
              '<a class="github-button" href="%s/issues" data-icon="octicon-issue-opened"  data-show-count="true" aria-label="Issue buttons/github-buttons on GitHub">Issue</a>',
              pkgs$package[[.x]]$repo
            ) |> as.character()
        )

       ) |>
       paste(collapse = "\n") |>
       as.character()
    }
  )
) |> write(
  sprintf("packages/index.qmd")
)



### Add a stream

#### Render all

stream <- yaml::read_yaml("stream/stream.yaml")

for (stream in stream$streams) {
  if (!dir.exists(sprintf("stream/%s/", stream$filename))) {
    dir.create(
      sprintf("stream/%s/", stream$filename)
    )
  }
  whisker::whisker.render(
    template = readLines("script/empty_stream.whisk"),
    data = list(
      name = stream$name,
      description = stream$description,
      who = stream$who,
      twitter_link = stream$twitter_link,
      twitter_name = stream$twitter_name,
      date = stream$date
    )
  ) |> write(
    sprintf("stream/%s/index.qmd", stream$filename)
  )
}

## Render confs

talks <- yaml::read_yaml("resources/talks.yaml")$talks

# Descending order
dates <- names(talks) |> sort() |> rev()

conf <- c()
for (date in dates){
  this_year <- talks[[date]] |>
    purrr::map_df(as.data.frame) |>
    dplyr::mutate(
      date = lubridate::ymd(date)
    ) |>
    dplyr::arrange(desc(date)) |>
    dplyr::mutate(
     content = sprintf(
      '- %s %s [%s](%s) %s, by [%s](%s)',
      date,
      emoji,
      title,
      link,
      lieu,
      author,
      author_link
     )
    )  |>
    dplyr::pull(content)

    conf <- c(conf, "\n", sprintf("## %s", date), "\n", this_year)

}

whisker::whisker.render(
  template = readLines("script/empty_resources.whisk"),
  data = list(
    confs = paste(conf, collapse = "\n")
  )
) |> write(
  sprintf("resources/index.qmd")
)
