class Player
  def play_turn(warrior)
    warrior.walk! warrior.direction_of_stairs
  end
end
