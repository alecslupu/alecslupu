---

title: How to implement Enum Fields in your Ruby on Rails models
date: 2013-02-03 00:00 UTC
tags: 
category: "Ruby on Rails" 

---

If you reached this page, it might be because you have searched how the hell you could create an enum field in Ruby On Rails.

Short answer: Ruby On Rails prior to version 4 does not know how to deal Enum fields, so you cannot declare enum fields. However, you can hack your model, and implement your own enum 🙂

### Code your own Enum Field

Long answer: Many developers need for a reason or another to have enum fields in their database. Maybe because they need to save a status of their object, or they need something more complex. By default Rails allows you to do this by using string fields, which later you could use to fetch your information by using scopes, or custom ActiveRecord or by declaring your own methods.

Personally i needed to have some enum fields in my Ruby on Rails applications, and i have seen that i am usually repeat the same stuff all over again, thing that lead me to write the snippet at the end of this post which later allowed me to use plain vanilla Enum fields into my Database.

First is I am creating my migration or my model where i add something like this:
    
    class CreateProducts < ActiveRecord::Migration  
      def up
        create_table :products do |t|
          t.string :name 
          t.integer :my_status_field, :limit => 1  #as a TinyInt 
          t.timestamps 
        end 
        add_index :products, :my_status_field 
      end
    
      def down 
        drop_table :products 
      end
    end

After i am creating the needed migration and the model, we are going to implement our status column inside a model.

    class Product < ActiveRecord::Base
      STATUS_ARRAY = {
        :pending             => 1,
        :open                => 2, 
        :closed              => 3, 
        :rejected            => 4, 
        :waiting_for_payment => 5 
      }
    
      has_enum_field :my_status_field, STATUS_ARRAY
    end

By using a snippet like the one above, you can easily use this kind of syntax:

    # Active Record Scopes:
    pending_products = Product.pending
    open_products    = Product.open
    # etc
    
    # inside an object, the following syntax
    
    object = Product.new
    object.my_status_field = :open
    
    object.is_pending?  # => false
    
    object.my_status_field = STATUS_ARRAY[:closed]
    object.pending?    # => false
    object.closed?     # => true
    object.is_closed?  # => true

But, wait, there is more:

1. you have presence validators
2. you can disable the number 1 validators
3. you can disable the boolean columns
4. you can diable the scopes

We are gonna take the above product class, and we will add another hash to our customize our enum snippet, by disabling the validators and scopes.

    class Product < ActiveRecord::Base
      STATUS_ARRAY = {
        :pending             => 1,
        :open                => 2,
        :closed              => 3,
        :rejected            => 4,
        :vaiting_for_payment => 5
      }
    
      ENUM_SETTINGS = {
        :validate => false,
        :scopes => false,
        :booleans => true
      }
    
      has_enum_field :my_status_field, STATUS_ARRAY, ENUM_SETTINGS
    end

Before running the below example, you might want to add in your “environment.rb” or “application.rb” a require statement to include the module globbaly into your project

Finally the module:

    module EnumField 
    class << self
      def included(klass) 
        klass.class_eval do 
          extend ClassMethods 
          include InstanceMethods 
        end 
      end 
    end
    
    module InstanceMethods
    end
    
    module ClassMethods
      def has_enum_field(column_name, data_set, options = {:validate => true, :scopes => true, :booleans => true})
        data_set.keys.each do |ds| 
          dat = data_set[ds.to_sym]
    
          class_eval %{
            validates_inclusion_of :#{column_name}, :in => #{data_set}.keys  
          } if options[:validate] 
    
          class_eval %{
            scope :#{ds}, where('#{column_name} = ?', dat)
          } if options[:scopes] 
    
          class_eval %{
            def #{ds}?
              self[:#{column_name}] == #{data_set}[:#{ds}]
            end
    
            alias_method :is_#{ds}?, :#{ds}?
          } if options[:booleans] 
    
          class_eval %{
            def #{column_name}=(value)
              self[:#{column_name}] = value.is_a?(Integer) ? value : #{data_set}[value.to_sym]
            end
    
            def #{column_name}
              #{data_set}.key(self[:#{column_name}])
            end
          }
        end
      end
    end
    end
    
    ActiveRecord::Base.send(:include, EnumField)


This module might have a problem thought, because is not 100% bullet proof. In order to achieve that, you might need to override the write_attribute method from Rails.
Update:

Once with release of Rails 4, this post can be deprecated, as it has been introduced by default in Rails. Please read more on the official wiki: [http://api.rubyonrails.org/v4.1.0/classes/ActiveRecord/Enum.html](http://api.rubyonrails.org/v4.1.0/classes/ActiveRecord/Enum.html)
