# frozen_string_literal: true
  
require_relative '../lib/darkmouun'

RSpec.describe Darkmouun do
  it "has a version number" do
    expect(Darkmouun::VERSION).not_to be nil
  end

  it "can convert a simple text" do
    expect(Darkmouun.document.new.convert('This is an RSpec test for Darkmouun.')).to eq '<p>This is an RSpec test for Darkmouun.</p>'
  end

  context "Template" do
    it "should work" do
      dkmn = Darkmouun.document.new
      dkmn.add_template(__dir__+"/01/test_template01.rb")
      dkmn.add_template(__dir__+"/01/test_template02.rb")
      expect(dkmn.convert(<<EOS)).to eq '<p>Dog is so pretty.</p>'
<<TmplTest01>>
animal: Dog

EOS
      expect(dkmn.convert(<<EOS)).to eq '<p>Snake is so terrible.</p>'
<<TmplTest02>>
animal: Snake

EOS
    end
  end
end
