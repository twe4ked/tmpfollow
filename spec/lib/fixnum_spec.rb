require_relative '../spec_helper'

describe Fixnum do
  describe 'ordinalize' do
    [
      [1, '1st'],
      [2, '2nd'],
      [3, '3rd'],
      [4, '4th'],
      [113, '113th']
    ].each do |num, expected|
      it "#{num} should be #{expected}" do
        num.ordinalize.should == expected
      end
    end
  end
end
