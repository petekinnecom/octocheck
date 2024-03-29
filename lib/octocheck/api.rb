require "uri"
require "net/http"
require "json"

module Octocheck
  class Api
    NotFoundError = Class.new(RuntimeError)

    attr_accessor :org, :branch, :repo, :token
    def initialize(org:, branch:, repo:, token:)
      @org = org
      @branch = branch
      @repo = repo
      @token = token

      @pr_links = []
    end

    def branch_link
      return unless branch

      "https://github.com/#{org}/#{repo}/tree/#{branch}"
    end

    def open_pr_link
      return unless branch

      "https://github.com/appfolio/apm_bundle/compare/#{branch}?expand=1"
    end

    def statuses
      get("repos/#{org}/#{repo}/commits/#{branch}/statuses")
        .map {|j|
          {
            name: j["context"],
            state: j["state"].downcase,
            target_url: j["target_url"]
          }
        }
        .uniq {|j| j[:name]}
    end

    def check_runs
      get("repos/#{org}/#{repo}/commits/#{branch}/check-runs")
        .fetch("check_runs")
        .map { |cr|
          @pr_links += (
            cr
            .fetch("pull_requests", [])
            .map { |pr| pr["number"] }
            .compact
            .map { |number| "https://github.com/#{org}/#{repo}/pull/#{number}" }
          )

          {
            name: cr["name"],
            state: cr["status"].downcase,
            github_url: "https://github.com/#{org}/#{repo}/runs/#{cr["id"]}",
            target_url: cr["details_url"],
            details: check_run_details(cr["output"]["summary"])
          }
        }
    end

    def pr_links
      @pr_links.uniq.sort
    end

    private

    def check_run_details(text)
      return [] unless text

      text
        .split("\n")
        .map { |r|
          structure = r.match(/\[(?<name>.+)\]\((?<url>.+)\) - (?<state>.*)$/)

          if structure
            {
              name: structure[:name],
              state: structure[:state].downcase,
              target_url: structure[:url]
            }
          else
            nil
          end
        }.compact
    end

    def get(path)
      url = File.join("https://api.github.com", path)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      headers.each do |k, v|
        request[k] = v
      end
      http.use_ssl = true
      response = http.request(request)
      raise NotFoundError.new("request failure:\n\n#{response.body}") unless response.code == "200"
      JSON.parse(response.body)
    end

    def headers
      {
        "Authorization" => "Token #{token}",
        "Accept" => "application/vnd.github.antiope-preview+json"
      }
    end
  end
end
