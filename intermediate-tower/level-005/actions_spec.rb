require 'actions'

describe Actions do
  describe 'drop' do
    it 'should drop options one at a time' do
      a = Actions.new
      a.drop(:walk!, :left)
      a.options[:walk!][:left].should == 0
    end

    it 'should drop multiple options' do
      a = Actions.new
      a.drop([[:walk!, :left], [:rescue!, :backward]])
      a.options[:walk!][:left].should == 0
      a.options[:rescue!][:backward].should == 0
    end
  end

  describe 'intersect' do
    it 'should work on full options' do
      a = Actions.new
      b = Actions.new
      a.intersect(b).should == b.options
    end

    it 'should skip dropped options' do
      a = Actions.new
      b = Actions.new
      a.drop(:walk!, :forward)
      a.intersect(b)
      a.options[:walk!][:forward].should == 0
    end

    it 'should skip dropped rest' do
      a = Actions.new
      b = Actions.new
      a.drop(:rest!, :here)
      a.intersect(b)
      a.options[:rest!][:here].should == 0
    end
  end
end
