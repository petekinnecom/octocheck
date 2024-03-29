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
        counts = {}
        cols = []
        summary.statuses.each do |status|
          counts[status.fetch(:state)] = (counts[status.fetch(:state)] || 0) + 1

          cols << [
            colorize(status.fetch(:state)),
            status.fetch(:name),
            gray(status.fetch(:target_url))
          ].join(" ")
        end

        summary.check_runs.each do |run|
          counts[run.fetch(:state)] = (counts[run.fetch(:state)] || 0) + 1

          cols << [
            colorize(run.fetch(:state)),
            run.fetch(:name),
            gray(run.fetch(:target_url))
          ].join(" ")

          run.fetch(:details).each do |detail|
            counts[detail.fetch(:state)] = (counts[detail.fetch(:state)] || 0) + 1

            cols << [
              colorize(detail.fetch(:state)),
              detail.fetch(:name),
              gray(detail.fetch(:target_url))
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

        output = [
          "",
          state_summaries,
          link_summaries,
        ]

        if summary.branch_link
          output += [
            "",
            "Branch:",
            summary.branch_link

          ]
        end

        (summary.pr_links || []).each do |repo_link|
          output += [
            "",
            "Pull Request:",
            repo_link
          ]
        end

        io.puts(output.join("\n"))
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
