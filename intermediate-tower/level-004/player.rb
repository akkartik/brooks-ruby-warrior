require 'coord'
require 'actions'

class Player
  def initialize
  end

  def play_turn(warrior)
    action, dir = Actions.new.pick
    action == :rest! ?
      warrior.send(action) :
      warrior.send(action, dir)
  end
end
