class Person
  attr_accessor :first_name, :last_name

  def initialize(first, last="")
    @first_name = first
    @last_name = last
  end

  def name
    first_name + " " + last_name
  end

end

bob = Person.new('Robert')
p bob.name                  # => 'Robert'
p bob.first_name            # => 'Robert'
p bob.last_name             # => ''
bob.last_name = 'Smith'
p bob.name
