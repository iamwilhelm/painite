module Timer
  def timer(label = nil)
    start_time = Time.now
    yield
    elapsed = (Time.now - start_time)
    unless label.nil?
      puts "#{label} took #{elapsed} secs"
    end
    return elapsed
  end
  module_function :timer
end
