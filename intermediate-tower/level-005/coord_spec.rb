require 'coord'

describe Coord do
  before(:all) do
    @coord = Coord.new
  end

  describe 'walk' do
    it 'should work for direction :left and :forward' do
      @coord.walk(:left).should == Coord.new(-1, 0)
      @coord.walk(:forward).should == Coord.new(0, 1)
    end

    it 'should oppose forward with backward and left with right' do
      @coord.walk(:left).walk(:right).should == @coord
      @coord.walk(:forward).walk(:backward).should == @coord
    end
  end

  describe 'hash equality' do
    it 'should hash equal objects to the same bucket' do
      h = Hash.new
      h[Coord.new(0, 0)] = true
      h[Coord.new(0, 0)] = false
      h.size.should == 1
    end
  end
end
