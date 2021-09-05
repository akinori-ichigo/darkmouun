# -*- coding: utf-8 -*-

require_relative "kramdown/parser/kramdown/extensions"
require_relative "kramdown/parser/kramdown/span"
require_relative "kramdown/parser/kramdown/link"
require_relative "kramdown/converter/html"

module Kramdown
  class Element
    CATEGORY[:span] = :span
  end

  module Parser
    class Kramdown
      alias_method :super_initialize, :initialize
      def initialize(source, options)
        super_initialize(source, options)
        @span_parsers.insert(5, :span)
      end
    end
  end
end

