## How to

### Add an article

article_slug <- "golem-playwright"
dir.create(
  file.path("news", article_slug)
)
file.create(
  file.path("news", article_slug, "index.qmd")
)
write(
  sprintf(
   '---
title: "Serve your {golem} app to {shinylive}"
author: colin
date: "%s"
draft: true
---', Sys.Date()
  ),
  file.path("news", article_slug, "index.qmd")
)
rstudioapi::navigateToFile(file.path("news", article_slug, "index.qmd"))
### Add a package

#### Render all packages

pkgs <- yaml::read_yaml("packages/packages.yaml")

for (i in seq_along(pkgs$package)) {
  pak <- names(pkgs$package)[i]
  p <- pkgs$package[[pak]]
  if (!file.exists(sprintf("packages/%s/", pak))){
    dir.create(
      sprintf("packages/%s/", pak)
    )
  }
  whisker::whisker.render(
    template = readLines("script/empty_package.whisk"),
    data = list(
      pkg = pak,
      order = i,
      title = p$title,
      # Plain-text one-liner for cards and <meta description>
      tagline = gsub('["`]', "", p$title),
      github = p$repo,
      repo_short = sub("https://github.com/", "", p$repo),
      description = p$description,
      lifecycle = p$lifecycle,
      cran = isTRUE(p$cran),
      # check defaults to TRUE; set `check: false` in packages.yaml for
      # non-R-package entries that have no R-CMD-check workflow.
      check = !isFALSE(p$check),
      category = p$category,
      category_lc = tolower(p$category)
    )
  ) |> write(
    sprintf("packages/%s/index.qmd", pak)
  )
}

#### Render the package index page

# The cards are Quarto listings filtered on the `tier` front matter; only the
# health table rows are generated here. Numbers are filled in the browser by
# gv-stats.js from the data-gv-* attributes.
whisker::whisker.render(
  template = readLines("script/empty_package_index.whisk"),
  data = list(
    n_packages = length(pkgs$package),
    content = names(pkgs$package) |>
      purrr::map_chr(function(pak) {
        p <- pkgs$package[[pak]]
        cran <- isTRUE(p$cran)
        sprintf(
          '<tr data-gv-repo="%s"%s><td><a class="gv-pkg" href="%s/"><img src="/img/%s.png" alt="">%s</a></td><td><span class="gv-pill gv-pill-%s">%s</span></td><td><span class="gv-dot gv-dot-%s"></span>%s</td><td>%s</td><td class="gv-num" data-gv="downloads">—</td><td class="gv-num" data-gv="stars">—</td><td class="gv-num" data-gv="issues">—</td><td data-gv="pushed">—</td></tr>',
          sub("https://github.com/", "", p$repo),
          if (cran) sprintf(' data-gv-cran="%s"', pak) else "",
          pak, pak, pak,
          tolower(p$category), p$category,
          p$lifecycle, p$lifecycle,
          if (cran) '<span class="gv-chip" data-gv="version">—</span>' else "—"
        )
      }) |>
      paste(collapse = "\n")
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
