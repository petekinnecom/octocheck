require "octocheck/formatters/color"

module Octocheck
  module Formatters
    class Iterm2
      GREEN_REGEX = /success|pass|completed|done/
      RED_REGEX = /fail|error/
      BLUE_REGEX = /progress|running/

      include Color
      attr_reader :io
      def initialize(io)
        @io = io
      end

      def format(summary)
        counts = {}
        cols = []
        summary.statuses.each do |status|
          counts[status.fetch(:state)] = (counts[status.fetch(:state)] || 0) + 1

          cols << [
            linkify(status.fetch(:state), status.fetch(:target_url)),
            status.fetch(:name)
          ].join(" ")
        end

        summary.check_runs.each do |run|
          counts[run.fetch(:state)] = (counts[run.fetch(:state)] || 0) + 1

          cols << [
            linkify(run.fetch(:state), run.fetch(:target_url)),
            run.fetch(:name)
          ].join(" ")

          run.fetch(:details).each do |detail|
            counts[detail.fetch(:state)] = (counts[detail.fetch(:state)] || 0) + 1

            cols << [
              linkify(detail.fetch(:state), detail.fetch(:target_url)),
              detail.fetch(:name)
            ].join(" ")
          end
        end

        io.puts(cols.join("\n"))

        state_summaries =
          counts
            .sort
            .map {|state, count| "#{count} #{state}"}
            .join(", ")

        link_summaries =
          summary
            .check_runs
            .map {|cr| cr.fetch(:github_url) }
            .join("\n")

        io.puts(["", state_summaries, link_summaries].join("\n"))
      end

      def linkify(text, url)
        colorized_text =
          if text.match(GREEN_REGEX)
            green(text)
          elsif text.match(RED_REGEX)
            red(text)
          elsif text.match(BLUE_REGEX)
            blue(text)
          else
            yellow(text)
          end

        "\e]8;;#{url}\a#{colorized_text}\e]8;;\a"
      end
    end
  end
end
