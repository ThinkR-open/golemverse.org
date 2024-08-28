## golemverse

Website for <https://golemverse.org>

## Blogging

Please refer to the how-to.R script on this page.

Note that streams & packages are generated via reading the yaml files at `/packages/packages.yaml` and `/stream/stream.yaml`.

## Publishing

This website is built with quarto, and for now uses the `freeze` feature to avoid re-rendering the blogposts on GitHub Action.

So before pushing, you'll need to run `quarto render`, and then send, ensuring that you have also added to git the `_freeze` folder.
