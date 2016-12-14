require 'unirest'
require 'date'
require_relative './constants.rb'

module BuyHatke
  class PriceData
    def initialize(product_id:, service:)
      @parameters = {
        pid: product_id,
        web: service
      }
    end

    def maximum
      sorted_by_price.last
    end

    def minimum
      sorted_by_price.first
    end

    def average
      parsed.map(&:last).reduce(:+) / parsed.length
    end

    def parsed
      @parsed ||= data
        .gsub(/\~\*\~\*/, "\n")
        .split(/\n/)
        .[](0..-2)
        .map do |line|
        l = line.split(/\~/)
        [
          l.first,
          l.last.to_i
        ]
      end
    end

    def sorted_by_price
      @sorted_by_price ||= parsed.sort { |l, r| l.last <=> r.last}
    end

    def data
      @data ||= download
    end

    def download
      Unirest
        .post(URL[:compare], parameters: @parameters)
        .body
    end
  end
end
