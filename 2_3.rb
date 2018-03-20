
require "pry"
class Person
  attr_accessor :first_name, :last_name

  def initialize(first, last="")
    @first_name = first
    @last_name = last
  end

  def name
    first_name + " " + last_name
  end

  def name=(n)
    self.first_name = n.split[0]
    self.last_name = n.split.size > 1 ? n.split[1] : ""
  end

end


bob = Person.new('Robert')
p bob.name                  # => 'Robert'
p bob.first_name            # => 'Robert'
p bob.last_name             # => ''
bob.last_name = 'Smith'
p bob.name                  # => 'Robert Smith'

bob.name = "John Adams"
p bob.first_name            # => 'John'
p bob.last_name             # => 'Adams'