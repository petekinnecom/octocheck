module Octocheck
  module Formatters
    module Color
      CODES = {
        gray: 30,
        red: 31,
        green: 32,
        yellow: 33,
        blue: 34,
        pink: 35,
      }.freeze

      CODES.each do |color, code|
        define_method(color) do |string|
          colorize_code(string, code)
        end
      end

      def colorize(string, color_name)
        return string unless CODES.key?(color_name)
        colorize_code(string, CODES[color_name])
      end

      private

      # colorization
      def colorize_code(string, color_code)
        "\e[#{color_code}m#{string}\e[0m"
      end
    end
  end
end
