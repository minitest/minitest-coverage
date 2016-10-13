require "example"

class Indirect
  def x
    Example.new.x
  end
end
