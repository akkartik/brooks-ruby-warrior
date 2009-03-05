require 'coord'
require 'actions'

class Player
  def initialize
    @health_history = []
  end

  def play_turn(warrior)
    @max_health ||= warrior.health
    @actions = Actions.new
    process_layers(warrior)
    pick_best_option(warrior)
  end

  def process_layers(warrior)
    run_from_fire(warrior)
    rest_when_low_health(warrior)
    skip_invalid(warrior)
  end

  # Layer 3
  def run_from_fire(warrior)
    if !@health_history.empty? && warrior.health < @health_history.last
      DIRS.each {|d| @actions.accentuate(:walk!, d, 3)}
    end
    @health_history << warrior.health
  end

  # Layer 2
  def rest_when_low_health(warrior)
    @actions.accentuate(:rest!, :here, 2) if warrior.health < @max_health
  end

  # Layer 1: valid
  def skip_invalid(warrior)
    skip_invalid_moves(warrior)
    skip_invalid_attacks(warrior)
    skip_invalid_rescues(warrior)
    skip_invalid_binds(warrior)
    skip_invalid_rest(warrior)
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

  def skip_invalid_rest(warrior)
    @actions.drop(:rest!, :here) if warrior.health == @max_health
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
