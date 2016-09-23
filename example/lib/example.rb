class Example
  def x
    y
  end

  def y
    42
  end
end

class IncidentalCoverage
  def x
    Example.new.x
  end
end
