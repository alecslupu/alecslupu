---

title: How to reduce code duplication
date: 2013-03-28 00:00 UTC
tags: 
category: "Ruby on Rails" 

---

By using Ruby or Pyton you might know about the fact that both are dynamically typed, as a result a developer can choose some of the variants available to remove some of the duplication. There are at least 2 methods that can be used to reduce code duplication.

#### Dynamic declaration:

    class MyClass
      STATUS_ARRAY = [ :pending, :closed, :rejected, :waiting_for_payment ]

      STATUS_ARRAY.each do |method|
        class_eval %{

          scope :#{method}, where('column_name = ?', #{method.to_sym})
    
          def #{method}?
            self[:column_name] == '#{method}'
          end

          alias :is_#{method}?, #{method}?
        }
      end
    end

In the example above we managed to write 8 lines that compress the code by declaring dynamically the equivalent of a 20 lines.

#### Inheritance

In Ruby you can easily use modules that you can include into your classes or you could use extend.

The below example you might encounter in all the Rails application upon class definitions, but this method is somehow limiting as you cannot extend with more than 1 class. In the below example we are extending the Foo class from Class1. Better said, Class1 is an ancestor of Foo

    class Foo < Class1
    end

However you could also use multiple inheritance by using the following example:

    class Foo
      extend Class1
      extend Class2
    end

The above example allows you to use several classes as a parent for Foo, however this might not be the best approach, because defies some OOP principles. As a workaround, is better to use modules.

Modules usage

    class Foo < Class1
      include Module1
      include Module2
    end

I have shown [here](http://www.alecslupu.ro/programming/2013/02/03/enum-field/) how to create a module
