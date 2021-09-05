# -*- coding: utf-8 -*-

require 'kramdown'

module Kramdown
  module Parser
    class Kramdown

      SPAN_START = /(?:\[\s*?)/

      # Parse the span at the current location.
      def parse_span
        start_line_number = @src.current_line_number
        saved_pos = @src.save_pos

        result = @src.scan(SPAN_START)
        stop_re = /(?:\s*?\])/

        el = Element.new(:span, nil, nil, :location => start_line_number)
        found = parse_spans(el, stop_re) do
          el.children.size > 0
        end

        if found
          @src.scan(stop_re)
          if @src.check(/\(/)
            @src.revert_pos(saved_pos)
            parse_link
            return
          end
          @tree.children << el
        else
          @src.revert_pos(saved_pos)
          @src.pos += result.length
          add_text(result)
        end
      end
      define_parser(:span, SPAN_START, '\[')

    end
  end
end
