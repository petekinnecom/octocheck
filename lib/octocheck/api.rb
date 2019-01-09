require "uri"
require "net/http"
require "json"

module Octocheck
  class Api
    attr_accessor :org, :branch, :repo, :token
    def initialize(org:, branch:, repo:, token:)
      @org = org
      @branch = branch
      @repo = repo
      @token = token
    end

    def statuses
      get("repos/#{org}/#{repo}/commits/#{branch}/statuses")
        .map {|j|
          {
            name: j["context"],
            state: j["state"].downcase,
            url: j["target_url"]
          }
        }
        .uniq {|j| j[:name]}
    end

    def check_runs
      get("repos/#{org}/#{repo}/commits/#{branch}/check-runs")
        .fetch("check_runs")
        .map { |cr|
          {
            name: cr["name"],
            state: cr["status"].downcase,
            url: cr["details_url"],
            details: check_run_details(cr["output"]["summary"])
          }
        }
    end

    private

    def check_run_details(text)
      text
        .split("\n")
        .map { |r|
          structure = r.match(/\[(?<name>.+)\]\((?<url>.+\)) - (?<state>.*)$/)

          if structure
            {
              name: structure[:name],
              state: structure[:state].downcase,
              url: structure[:url]
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
      raise "request failure:\n\n#{response.body}" unless response.code == "200"
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
