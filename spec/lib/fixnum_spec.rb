require 'spec_helper'

describe Fixnum do
  describe 'ordinalize' do
    it 'ordinalizes numbers correctly' do
      [
        [1, '1st'],
        [2, '2nd'],
        [3, '3rd'],
        [4, '4th'],
        [113, '113th']
      ].each do |num, expected|
          num.ordinalize.should == expected
      end
    end
  end
end
