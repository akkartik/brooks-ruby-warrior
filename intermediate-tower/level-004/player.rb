require 'coord'
require 'actions'

class Player
  def initialize
  end

  def play_turn(warrior)
    @actions = Actions.new
    process_layers(warrior)
    @actions.show_all_options
    pick_best_option(warrior)
  end

  def process_layers(warrior)
#?     run_from_fire(warrior)
#?     rest_when_low_health(warrior)
    skip_invalid(warrior)
  end

  # Layer 1: valid
  def skip_invalid(warrior)
    skip_invalid_moves(warrior)
    skip_invalid_attacks(warrior)
    skip_invalid_rescues(warrior)
    skip_invalid_binds(warrior)
  end

  def skip_invalid_moves(warrior)
    DIRS.each {|dir| @actions.drop(:walk!, dir) unless warrior.feel(dir).empty?}
  end

  def skip_invalid_attacks(warrior)
    DIRS.each {|dir| @actions.drop(:attack!, dir) unless hostile_space?(warrior.feel(dir))}
  end
  def skip_invalid_binds(warrior)
    DIRS.each {|dir| @actions.drop(:bind!, dir) unless hostile_space?(warrior.feel(dir))}
  end

  def skip_invalid_rescues(warrior)
    DIRS.each {|dir| @actions.drop(:rescue!, dir) unless warrior.feel(dir).captive?}
  end

  def hostile_space?(space)
    !space.empty? && !space.captive? && !space.stairs? && !space.wall?
  end

  ## Layer 0: random
  def pick_best_option(warrior)
    action, dir = @actions.pick
    action == :rest! ?
      warrior.send(action) :
      warrior.send(action, dir)
  end
end
