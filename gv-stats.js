// Fills [data-gv="…"] placeholders with live numbers. Containers opt in with
// data-gv-repo="owner/repo" (stars, issues, last commit) and data-gv-cran="pkg"
// (CRAN version, monthly downloads, pkgdown URL).
//
// GitHub repos are queried in batches: the search API takes several `repo:`
// qualifiers at once, so the packages page costs 2 requests instead of 17.
// Everything is cached per repo/package for an hour, so moving between pages
// usually costs nothing.
(function () {
  var TTL = 60 * 60 * 1000;
  // GitHub documents a 256-character limit on search queries.
  var MAX_QUERY = 240;
  var fmt = new Intl.NumberFormat("en-US");

  function readCache(key) {
    try {
      var c = JSON.parse(localStorage.getItem(key));
      if (c && Date.now() - c.t < TTL) return c.v;
    } catch (e) {}
    return null;
  }

  function writeCache(key, value) {
    try { localStorage.setItem(key, JSON.stringify({ t: Date.now(), v: value })); } catch (e) {}
  }

  function getJSON(url) {
    return fetch(url).then(function (r) {
      if (!r.ok) throw new Error(url + " " + r.status);
      return r.json();
    });
  }

  // Every container carrying `attr`, grouped by its value (lowercased, since
  // packages.yaml and the GitHub API disagree on the casing of owner names).
  function targets(attr) {
    var map = {};
    document.querySelectorAll("[" + attr + "]").forEach(function (el) {
      var key = el.getAttribute(attr).toLowerCase();
      (map[key] = map[key] || []).push(el);
    });
    return map;
  }

  function paint(els, values) {
    els.forEach(function (el) {
      Object.keys(values).forEach(function (key) {
        var value = values[key];
        if (value == null || value === "") return;
        el.querySelectorAll('[data-gv="' + key + '"]').forEach(function (node) {
          if (node.tagName === "A") { node.href = value; node.hidden = false; }
          else { node.textContent = value; }
        });
      });
    });
  }

  // Split the repo list so no single search query exceeds MAX_QUERY.
  function batches(repos) {
    var out = [], current = [], length = 0;
    repos.forEach(function (repo) {
      var cost = repo.length + 6; // "repo:" plus the separator
      if (current.length && length + cost > MAX_QUERY) { out.push(current); current = []; length = 0; }
      current.push(repo);
      length += cost;
    });
    if (current.length) out.push(current);
    return out;
  }

  var repos = targets("data-gv-repo");
  var pending = Object.keys(repos).filter(function (repo) {
    var cached = readCache("gv-gh-" + repo);
    if (cached) paint(repos[repo], cached);
    return !cached;
  });

  batches(pending).forEach(function (batch) {
    var query = batch.map(function (repo) { return "repo:" + repo; }).join("+");
    getJSON("https://api.github.com/search/repositories?q=" + query + "&per_page=100")
      .then(function (d) {
        (d.items || []).forEach(function (item) {
          var repo = item.full_name.toLowerCase();
          var values = {
            stars: fmt.format(item.stargazers_count),
            issues: fmt.format(item.open_issues_count),
            pushed: (item.pushed_at || "").slice(0, 7)
          };
          writeCache("gv-gh-" + repo, values);
          paint(repos[repo] || [], values);
        });
      })
      .catch(function () {});
  });

  var packages = targets("data-gv-cran");
  Object.keys(packages).forEach(function (pkg) {
    var cached = readCache("gv-cran-" + pkg);
    if (cached) return paint(packages[pkg], cached);
    getJSON("https://cran.r-universe.dev/api/packages/" + pkg)
      .then(function (d) {
        var values = {
          version: d.Version,
          downloads: d._downloads && d._downloads.count != null ? fmt.format(d._downloads.count) : null,
          pkgdown: d._pkgdown
        };
        writeCache("gv-cran-" + pkg, values);
        paint(packages[pkg], values);
      })
      .catch(function () {});
  });
})();
