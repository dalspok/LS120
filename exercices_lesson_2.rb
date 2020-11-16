# class Person
#   attr_accessor :first_name, :last_name

#   def initialize(first_name, last_name="")
#     @first_name = first_name
#     @last_name = last_name
#   end

#   def name
#     (last_name.empty?) ? first_name : [first_name, last_name].join(" ")
#   end

#   def name=(string)
#     self.first_name, last = string.split
#     self.last_name = last if last
#   end

#   def ==(other_person)
#     name == other_person.name
#   end

# end


# bob = Person.new('Robert Smith')
# rob = Person.new('Robert Smith')

# p bob == rob


### Inheritance

class Animal
  def run
    'running!'
  end

  def jump
    'jumping!'
  end

    def speak
    'bark!'
  end
end

class Dog < Animal

  def swim
    'swimming!'
  end

  def fetch
    'fetching!'
  end
end

class Cat < Animal

end

p Dog.new.swim
p Cat.new.swim



