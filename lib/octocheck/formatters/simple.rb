require "octocheck/formatters/color"

module Octocheck
  module Formatters
    class Simple
      GREEN_REGEX = /success|pass|completed|done/
      RED_REGEX = /fail|error/
      BLUE_REGEX = /progress|running/

      include Color
      attr_reader :io
      def initialize(io)
        @io = io
      end

      def format(summary)
        cols = []
        summary.statuses.each do |status|
          cols << [
            colorize(status.fetch(:state)),
            status.fetch(:name),
            status.fetch(:url)
          ].join(" ")
        end

        summary.check_runs.each do |run|
          cols << [
            colorize(run.fetch(:state)),
            run.fetch(:name),
            run.fetch(:url)
          ].join(" ")

          run.fetch(:details).each do |detail|
            cols << [
              colorize(detail.fetch(:state)),
              detail.fetch(:name),
              detail.fetch(:url)
            ].join(" ")
          end
        end

        io.puts(cols.join("\n"))
      end

      def colorize(text)
        if text.match(GREEN_REGEX)
          green(text)
        elsif text.match(RED_REGEX)
          red(text)
        elsif text.match(BLUE_REGEX)
          blue(text)
        else
          yellow(text)
        end
      end
    end
  end
end
