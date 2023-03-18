# Darkmouun

## Overview

Darkmouun is the converter from a markdown text enhanced by [kramdown](https://github.com/gettalong/kramdown) to a HTML document.

Darkmouun can define: 
  * Pre-processing (to a markdown document)
  * Extracting templates by Mustache
  * Converting from markdown to HTML by kramdown
  * Post-processing (to a HTML document)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'darkmouun'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install darkmouun

## Usage

Darkmouun instance is made by `Darkmouun.document.new` with no arguments.

(Darkmouun instance)`.convert` makes a HTML document from the markdown text and takes 3 arguments.

* 1st arg: Markdown text (String)
* 2nd arg: Kramdown's parser option (Hash) (cf. [kramdown's usage](https://kramdown.gettalong.org/documentation.html#usage))
* 3rd arg: Kramdown's converter name (Symbol)

2nd and 3rd argument have default values. 

* 2nd arg: `{}`
* 3rd arg: `:to_html`

You can define pre_process and post_process as Proc object.

```
dkmn = Darkmouun.document.new
dkmn.pre_process = lambda do |i|
  i.gsub!(/MARKDOWN/, "Markdown")
end
dkmn.post_process = lambda do |i|
  i.gsub!(/DOCUMENT/, "Document")
end
dkmn.convert("MARKDOWN DOCUMENT")  #=> "<p>Markdown Document</p>
```

You can write the parts that Mustache extracts with templates in your markdown document.
Template is written as Ruby script, and it is made to define as the subclass of Mustache class.

The part of template extacting in the markdown document starts `<<template_name>>`.
Parameters of the template are written below with YAML format.

```
# Template file 'templates/template_a.rb'

class Template_A < Mustache
  Template = <<EOS
'<p>{{fig1}} + {{fig2}}' is {{calc}}.</p>
EOS

def calc
  (fig1.to_i + fig2.to_i).to_s
end
```

```
# converting code

dkmn = Darkmouun.document.new
dkmn.add_template("#{__dir__}/templates/template_a.rb")
dkmn.convert(<<BODY)
The calculation:

<<Template_A>>
fig1: 1
fig2: 2
BODY    #=> <p>The Calculation:</p>
        #=> <p>1 + 2 is 3.</p>
```

## kramdown extensions

Darkmouun has extended to kramdown. Extensions are below;

1. **Plain span element form.** `[spanned phrase]` is converted to `<span>spanned phrase</span>`.<br/>**ATTENSION:** You must add IAL with it. Without IAL, No conversion is done.<br/>**ex.** `[spanned phrase]{:#some_id .some_class style="color:red;"}`

2. **Style IAL form.** `%attritute_name:value;` in IAL is converted to `style="attribute_name:value;"`.<br/>**ex.** `{:%color:#ffffff; %font-weight:bold;}` -> `style="color:#ffffff; font-weight:bold;"`<br/>**ATTENSION:** Every attribute must be started from "`%`" and ended with "`;`".

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Darkmouun project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/darkmouun/blob/master/CODE_OF_CONDUCT.md).
