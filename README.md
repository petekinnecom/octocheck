See github status checks in your terminal. (https://help.github.com/en/articles/about-status-checks)

Bonus: displays a link to an existing PR!
Super bonus: displays a link to open a PR if one doesn't exist!
Super extra bonus: use this in front of your non-programmer friends and they will think you are a super cool hacker!

```
$ octocheck

success     ci-check-1  https://example.com/ci-check-1
in_progress ci-check-2  https://example.com/ci-check-2
failed      ci-check-3  https://example.com/ci-check-3

Branch:
https://github.com/org/repo/tree/branchname

PR:
https://github.com/org/repo/pull/174

```

### Installation

Requires ruby > 2.1.0

```
gem install octocheck
```

### OPTIONS

```
-b, --branch: defaults to current repo's branch
-p, --project: defaults to repo directory name
-o, --org: the Github org that owns the repo (see CONFIGURATION below)
-r, --revision: defaults to latest revision on current branch
-t, --token: your github API token (see CONFIGURATION below)
```

### CONFIGURATION

You can specify your github org and token in a configuration file so
that you don't need to configure them each time.

Put a json formatted file at ~/.config/octocheck/config.json with the
following data:

```json
  {
    "token": "< github token value >",
    "org": "< github org name >"
  }
```

### ORG

Unfortunately when accessing status checks for a repo, the repo's
organization must be specified. :(  The organization can be found in
the repo's url:

https://github.com/ORGNAME/repo_name

### TOKEN

In order to read Github checks, you need to configure (or pass as an
argument) a token with rights to "repo" permissions:

1. Visit https://github.com/settings/tokens/new
2. Generate a new token
3. Grant the `repo` permission (leave all others unchecked)
4. Paste the token in the configuration file as specified in CONFIGURATION.

Unfortunately full `repo` access is needed in order to access Github
status checks. Hopefully they change that soon.

### OUTPUT

Checks are listed in the order they are received. There is some basic
colorization applied based on the status names. When using Iterm2, the
status names are links to the check target. Other terminals have the
link appended to the output.
