require 'actions'

describe Actions do
  describe 'intersect' do
    it 'should work' do
      Actions.new({}).intersect(Actions.new({:walk! => []})).should be_empty
      Actions.new({:walk! => [:left]}).intersect(Actions.new({:walk! => [:right]})).should be_empty
      Actions.new({:walk! => [:left, :right]}).intersect(Actions.new({:walk! => [:right]})).should_not be_empty
    end

    it 'should work for rest!' do
      Actions.new({}).intersect(Actions.new({:rest! => 1})).should be_empty
      Actions.new({:rest! => [1]}).intersect(Actions.new({:rest! => [1]})).should_not be_empty
    end
  end
end
