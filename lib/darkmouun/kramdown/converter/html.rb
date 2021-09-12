# -*- coding: utf-8 -*-

require 'kramdown'

module Kramdown
  module Converter
    class Html
      def convert_span(el, indent)
        if el.attr.empty?
          "[#{inner(el, indent)}]"
        else
          format_as_span_html('span', el.attr, inner(el, indent))
        end
      end
    end
  end
end

