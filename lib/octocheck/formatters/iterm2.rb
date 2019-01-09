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
        cols = []
        summary.statuses.each do |status|
          cols << [
            linkify(status.fetch(:state), status.fetch(:url)),
            status.fetch(:name)
          ].join(" ")
        end

        summary.check_runs.each do |run|
          cols << [
            linkify(run.fetch(:state), run.fetch(:url)),
            run.fetch(:name)
          ].join(" ")

          run.fetch(:details).each do |detail|
            cols << [
              linkify(detail.fetch(:state), detail.fetch(:url)),
              detail.fetch(:name)
            ].join(" ")
          end
        end

        io.puts(cols.join("\n"))
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
