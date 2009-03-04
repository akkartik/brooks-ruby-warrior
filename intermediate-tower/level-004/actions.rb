class Actions
  attr_accessor :options

  def initialize
    @options = {
      :walk! => [:left, :right, :forward, :backward],
      :rescue! => [:left, :right, :forward, :backward],
      :attack! => [:left, :right, :forward, :backward],
      :bind! => [:left, :right, :forward, :backward],
      :rest! => [1],
    }
  end

  def initialize(h)
    @options = h
  end

  def intersect(action)
    new_options = {}
    action.options.each do |a, o|
      new_options[a] = intersect_row @options[a], o
    end
    @options = new_options.reject{|k, v| v.nil? || v.empty?}
  end

  private

  def intersect_row(a, b)
    return nil if a.nil? || b.nil?
    a.inject([]) {|ans, dir| b.include?(dir) ? ans << dir : ans}
  end
end
