# -*- coding: utf-8 -*-

require_relative "kramdown/parser/kramdown/extensions"
require_relative "kramdown/parser/kramdown/span"
require_relative "kramdown/parser/kramdown/link"
require_relative "kramdown/converter/html"

module Kramdown
  class Element
    CATEGORY[:span] = :span
  end
end

