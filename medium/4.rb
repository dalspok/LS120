class Greeting
  def greet(how)
    puts how
  end
end

class Hello < Greeting
  def hi
    greet "hello"
  end
end

class Goodbye < Greeting
  def bye
    greet "goodbye"
  end
end

Goodbye.new.bye
Hello.new.hi