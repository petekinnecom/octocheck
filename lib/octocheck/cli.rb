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

      using_iterm2 = (
        ENV["TERM_PROGRAM"] == "iTerm.app" &&
        ENV.fetch("TERM_PROGRAM_VERSION", "").match(/3.[23456789]/)
      )

      formatter =
        if using_iterm2
          Formatters::Iterm2
        else
          Formatters::Simple
        end

      formatter.new($stdout).format(summary)
    end
  end
end
