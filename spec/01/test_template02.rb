# coding: utf-8

require 'mustache'

class TmplTest02Super < Mustache; end

class TmplTest02 < TmplTest02Super
  @template = <<EOT
{{animal}} is so terrible.
EOT
end

