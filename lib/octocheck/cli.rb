require "octocheck/api"
require "octocheck/summary"
require "octocheck/formatters/iterm2"
require "octocheck/formatters/simple"

module Octocheck
  class CLI
    def self.call(org:, branch:, repo:, token:)
      api = Api.new(
        org: org,
        branch: branch,
        repo: repo,
        token: token
      )

      summary = Summary.new(
        api: api
      )

      using_iterm2 = ["iTerm.app", "vscode"].include?(ENV["TERM_PROGRAM"])

      formatter =
        if using_iterm2
          Formatters::Iterm2
        else
          Formatters::Simple
        end

      formatter.new($stdout).format(summary)
    rescue Api::NotFoundError
      warn <<~TXT
        Couldn't fetch info for this branch. Some things to check:

        - Has it been pushed to Github?
        - Does this repo have status checks enabled?

        Branch:
        #{summary.branch_link}

      TXT
      exit(1)
    end
  end
end
