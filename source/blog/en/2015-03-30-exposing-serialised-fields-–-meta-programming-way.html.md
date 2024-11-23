---

title: Exposing serialised fields – meta programming way
date: 2015-03-30 00:00 UTC
tags: 

---

    class SomeClass < ActiveRecord::Base
      belongs_to :user
    
      def self.serialize(attr_name, class_name = Object, exposed_fields = [])
        super(attr_name, class_name)
        serialized_attr_accessor attr_name, exposed_fields
      end
    
      def self.serialized_attr_accessor(attr_name, *args)
        args.first.each do |method_name|
          eval "
            def #{method_name}
              (self[:#{attr_name}] || {})[:#{method_name}]
            end

            def #{method_name}=(value)
              self[:#{attr_name}] ||= {}
              self[:#{attr_name}][:#{method_name}] = value
            end
            attr_accessible :#{method_name}
          "
        end
      end
    
      serialize :other_data, Hash, 
        %w(some other values you want to store in serialized field)
    end
