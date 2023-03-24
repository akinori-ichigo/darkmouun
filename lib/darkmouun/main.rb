# -*- coding: utf-8 -*-

require "mustache"
require "Kramdown"
require "htmlbeautifier"

require_relative "kramdown"

module Darkmouun
  class << self
    def document
      Darkmouun
    end
  end

  class Darkmouun
    attr_accessor :pre_process, :post_process
  
    def initialize
      @templates = {}
    end

    def add_template(tmpl)
      # for Mustache
      tmpl_module = Module.new
      tmpl_module.module_eval(File.read(tmpl), tmpl)
      tmpl_module.constants.each do |i|
        c = tmpl_module.const_get(i)
        if c.is_a?(Class) && c.superclass == Mustache
          @templates[i] = c
        end
      end
    end

    def convert(source, options = {}, converter = :to_html)
      @source = source
      do_pre_process
      apply_mustache
      apply_kramdown(options, converter)
      do_post_process
      beautify
    end

    private

    def do_pre_process
      begin
        @pre_process.call(@source) unless @pre_process.nil?
      rescue => e
        raise e.class.new("\n#{e.message}\n\n>>> ERROR in \"Pre-process\" <<<\n")
      end
    end

    def apply_mustache
      @source = @source.gsub(/<<(.+?)>>(\n\n|(?:\n|.)+?\n\n)/) do |s|
        begin
          obj_spot_template = (@templates[$~[1].to_sym]).new
          yaml = YAML.load($~[2].strip)
          yaml = {$~[1].downcase => yaml} unless yaml.is_a?(Hash)
          yaml.compact.each do |k, v|
            obj_spot_template.define_singleton_method(k){ v }
          end
          obj_spot_template.render + "\n"
        rescue => e
          e.class.new("**ERROR in Mustache-process:**\n\n#{e.message}\n\nThis was caused by the following defnition.\n\n    #{s}\n\n")
        end
      end
    end

    def apply_kramdown(options, converter)
      begin
        @result = Kramdown::Document.new(@source, options).send(converter)
      rescue => e
        raise e.class.new("\n#{e.message}\n\n>>> ERROR in \"kramdown-process\" <<<\n")
      end
    end

    def do_post_process
      begin
        @post_process.call(@result) unless @post_process.nil?
      rescue => e
        raise e.class.new("\n#{e.message}\n\n>>> ERROR in \"Post-process\" <<<\n")
      end
    end

    def beautify
      HtmlBeautifier.beautify(@result)
    end
  
  end
end
