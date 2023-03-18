# coding: utf-8

require 'mustache'

class TmplTest01 < Mustache
  @template = <<EOT
{{animal}} is so pretty.
EOT
end

