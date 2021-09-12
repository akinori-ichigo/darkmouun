# -*- coding: utf-8; frozen_string_literal: true -*-
#
#--
# Copyright (C) 2009-2019 Thomas Leitner <t_leitner@gmx.at>
#
# This file is part of kramdown which is licensed under the MIT.
#++
#

require 'kramdown/parser/kramdown/escaped_chars'

module Kramdown
  module Parser
    class Kramdown

      # Parse the link at the current scanner position. This method is used to parse normal links as
      # well as image links, plain spans.
      def parse_link
        start_line_number = @src.current_line_number
        result = @src.scan(LINK_START)
        cur_pos = @src.pos
        saved_pos = @src.save_pos

        link_type = (result =~ /^!/ ? :img : :a)

        # no nested links allowed
        if link_type == :a && (@tree.type == :img || @tree.type == :a ||
                               @stack.any? {|t, _| t && (t.type == :img || t.type == :a) })
          add_text(result)
          return
        end
        el = Element.new(link_type, nil, nil, location: start_line_number)

        count = 1
        found = parse_spans(el, LINK_BRACKET_STOP_RE) do
          count += (@src[1] ? -1 : 1)
          count - el.children.select {|c| c.type == :img }.size == 0
        end
        unless found
          @src.revert_pos(saved_pos)
          add_text(result)
          return
        end
        alt_text = extract_string(cur_pos...@src.pos, @src).gsub(ESCAPED_CHARS, '\1')
        @src.scan(LINK_BRACKET_STOP_RE)

        # reference style link or no link url
        if @src.scan(LINK_INLINE_ID_RE) || !@src.check(/\(/)
          emit_warning = !@src[1]
          link_id = normalize_link_id(@src[1] || alt_text)
          if @link_defs.key?(link_id)
            link_def = @link_defs[link_id]
            add_link(el, link_def[0], link_def[1], alt_text,
                     link_def[2] && link_def[2].options[:ial])
          else
            if emit_warning
              warning("No link definition for link ID '#{link_id}' found on line #{start_line_number}")
            end
            @src.revert_pos(saved_pos)
            if @src.check(/./) == ']'
              add_text(result)
            else
              parse_span
            end
          end
          return
        end

       # link url in parentheses
       if @src.scan(/\(<(.*?)>/)
         link_url = @src[1]
         if @src.scan(/\)/)
           add_link(el, link_url, nil, alt_text)
           return
         end
       else
         link_url = +''
         nr_of_brackets = 0
         while (temp = @src.scan_until(LINK_PAREN_STOP_RE))
           link_url << temp
           if @src[2]
             nr_of_brackets -= 1
             break if nr_of_brackets == 0
           elsif @src[1]
             nr_of_brackets += 1
           else
             break
           end
         end
         link_url = link_url[1..-2]
         link_url.strip!

         if nr_of_brackets == 0
           add_link(el, link_url, nil, alt_text)
           return
         end
       end

       if @src.scan(LINK_INLINE_TITLE_RE)
         add_link(el, link_url, @src[2], alt_text)
       else
         @src.revert_pos(saved_pos)
         add_text(result)
       end
     end
#      define_parser(:link, LINK_START, '!?\[')

    end
  end
end
