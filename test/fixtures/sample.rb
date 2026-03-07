# frozen_string_literal: true

module Animals
  class Dog
    attr_reader :name, :breed

    def initialize(name, breed)
      @name = name
      @breed = breed
    end

    def bark
      "Woof! My name is #{@name}"
    end

    def fetch(item)
      "#{@name} fetches the #{item}!"
    end
  end

  class Cat
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def meow
      "Meow! I'm #{@name}"
    end

    def purr
      "Purrrr..."
    end

    def ignore_human
      "#{@name} looks away disdainfully."
    end
  end

  class Shelter
    def initialize
      @animals = []
    end

    def add(animal)
      @animals << animal
    end

    def list
      @animals.map do |a|
        "#{a.class.name}: #{a.name}"
      end
    end

    def count
      @animals.size
    end
  end
end
