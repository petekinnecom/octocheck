module Octocheck
  class Summary
    attr_accessor :api
    def initialize(api:)
      @api = api
    end

    def check_runs
      @check_runs ||= api.check_runs
    end

    def statuses
      @statuses ||= api.statuses
    end

    def summary_pages
      @summary_pages ||= api.summary_pages
    end
  end
end
