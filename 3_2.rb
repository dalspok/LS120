
class Pets
  def speak
    'bark!'
  end

  def run
    'running!'
  end

  def jump
    'jumping!'
  end
end

class Dog < Pets
  def swim
    'swimming!'
  end

  def fetch
    'fetching!'
  end
end

class Cat < Pets

end