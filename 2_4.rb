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

  def ==(other_object)
    self.name == other_object.name
  end

end

bob = Person.new('Robert Smith')
rob = Person.new('Robert Smith')

p bob == rob