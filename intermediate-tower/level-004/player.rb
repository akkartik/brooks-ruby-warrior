require 'coord'
require 'actions'

class Player
  def initialize
    @health_history = []
  end

  def play_turn(warrior)
    preprocess warrior
    process_layers
    pick_best_option
    postprocess
  end

  def preprocess(warrior)
    @warrior = warrior
    @max_health ||= @warrior.health
    @actions = Actions.new
  end

  def postprocess
    @health_history << @warrior.health
  end

  def process_layers
    look_for_captives
    look_for_hostiles
    run_from_fire
    rest_when_low_health
    skip_invalid
  end

  # Layer 5
  def look_for_captives
  end

  # Layer 4
  def look_for_hostiles
  end

  # Layer 3
  def run_from_fire
    return if @health_history.empty? || @warrior.health >= @health_history.last
    DIRS.each {|d| @actions.accentuate(:walk!, d, 3)}
  end

  # Layer 2
  def rest_when_low_health
    @actions.accentuate(:rest!, :here, 2) if @warrior.health < @max_health
  end

  # Layer 1: valid
  def skip_invalid
    skip_invalid_moves
    skip_invalid_attacks
    skip_invalid_rescues
    skip_invalid_binds
    skip_invalid_rest
  end

  def skip_invalid_moves
    DIRS.each {|dir| @actions.drop(:walk!, dir) unless @warrior.feel(dir).empty?}
  end

  def skip_invalid_attacks
    DIRS.each {|dir| @actions.drop(:attack!, dir) unless hostile_space?(@warrior.feel(dir))}
  end
  def skip_invalid_binds
    DIRS.each {|dir| @actions.drop(:bind!, dir) unless hostile_space?(@warrior.feel(dir))}
  end

  def skip_invalid_rescues
    DIRS.each {|dir| @actions.drop(:rescue!, dir) unless @warrior.feel(dir).captive?}
  end

  def skip_invalid_rest
    @actions.drop(:rest!, :here) if @warrior.health == @max_health
  end

  def hostile_space?(space)
    !space.empty? && !space.captive? && !space.stairs? && !space.wall?
  end

  # Layer 0: random
  def pick_best_option
    action, dir = @actions.pick
    action == :rest! ?
      @warrior.send(action) :
      @warrior.send(action, dir)
  end
end
