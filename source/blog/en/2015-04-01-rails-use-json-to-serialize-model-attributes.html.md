---

title: Rails: Use JSON to serialize model attributes
date: 2015-04-01 00:00 UTC
tags: 

---

Scalling a Rails application’s response is often done by using another programming language. As we might know, Twitter has started as a Rails application, and ended up as Scala, or later as a Javascript backend application.

In my oppinion, a first step to this kind of migration would consist in normalising all the serialised data you have in your database.

Personally, i use [ActiveRecord::Base#serialize](http://api.rubyonrails.org/classes/ActiveRecord/AttributeMethods/Serialization/ClassMethods.html#method-i-serialize) method to handle most of the custom data that can be resulted by a STI model, or to store any dynamic extra data. I consider to be a good example the situation when you need to keep some additional information about the user, like the company info if is a company .

Some of the Ruby on Rails projects are starting to use plain serialize method, which can be exemplified by Ryan Bates tutorial named [PayPal Notifications](http://railscasts.com/episodes/142-paypal-notifications?view=asciicast), or by [Diaspora’s codebase](https://github.com/diaspora/diaspora/blob/2619beb157f618094e2cbfaf65f89f24441f25d5/app/models/o_embed_cache.rb#L2) or [Spree codebase](https://github.com/spree/spree/search?l=ruby&q=serialize&utf8=%E2%9C%93).

One easy trick that you can do in any 3.x & 4.x application is to define your serialize method like :

    class User < ActiveRecord::Base
      serialize :other_data, JSON
    end

This way your application will use JSON column coder, which in my opinion, is a better alternative which fixes some of the problems for you:

* Allows you to use same database backend for multiple applications, written in multiple languages (if is the case)
* Avoids Syck vs Psych serialization problems (Psych is default Yaml-er starting with Ruby 1.9.3)
* Json is much faster than Yaml (check [here](http://pjkh.com/articles/postgresql-json-vs-rails-serialize/), [here](http://www.pauldix.net/2008/08/serializing-dat.html) and [here](http://itcourses.cs.unh.edu/assets/docs/704/reports/fall14/Comparison%20of%20JSON%20and%20YAML%20-%20Brandon%20Schwarzer.pdf))

Some of the problems caused by YAML are described in [Arne Brasseur’s](http://devblog.arnebrasseur.net/2014-02-yaml-syck-vs-psych) post.

### Updating an existing application to use JSON serialized fields

In order to make your existing application to use JSON serialized field, you would need to perform some changes to your models, mainly to convert:

    class User < ActiveRecord::Base
      serialize :other_data
    end

To

    class User < ActiveRecord::Base
      serialize :other_data, JSON
    end

Notice the “JSON”, argument for the serialize method.

Other change that you would need to do is to add a migration to change your existing data, from YAML serialized string to JSON serialized string. To do so, you would need to add a migration or a code snippet somewhere in your application to perform the conversion operation:

    class ChangeSerializationOnUser < ActiveRecord::Migration
      class YamlUser < ActiveRecord::Base
        self.table_name ="users"
        serialize :other_data
      end
    
      class JsonUser  < ActiveRecord::Base
        self.table_name ="users"
        serialize :other_data, JSON
      end
    
      def up
        YamlUser.where(other_data: '---
        ').update_all(other_data: nil)
    
        YamlUser.find_each do |yaml_user|
          next unless yaml_user.other_data.present?
          next unless yaml_user.other_data.respond_to?(:to_hash)
          hash = yaml_user.other_data.to_hash
    
          JsonUser.where(id: yaml_user.id).update_all(other_data: nil)
          json_user = JsonUser.find(yaml_user.id)
          json_user.other_data = hash || {}
          json_user.save!
        end
      end
    
      def down
        raise ActiveRecord::IrreversibleMigration
      end
    end

The migration above is doing the following things:

* Defines a YamlUser class that would handle the Yaml serialize part of your migration. Assuming you added JSON parameter to your class, YamlUser is performing the simple task of converting from string to whatever data you have serialized.
* Defines a JsonUser class that would handle the JSON serialize part of your migration. This class is defined to perform one single thing, that to convert and save the serialized info field, without validations, without ActiveRecord callbacks.
* Cleans up all the empty serialized objects. Depending of your data, you might add also an update for  ‘— \n[]'
* Sometimes, the information you have saved might come as an HashWithIndifferentAccess, which for this operation would require a manual deserialization. That is why, i am using .to_hash
* Before instantiating a JsonUser object, we would need to update the record in order to avoid any errors caused by the object hydration.
* Of course, i consider this to be an “ActiveRecord::IrreversibleMigration”

I consider this to be a first step in order to migrate to multiple backend applications.

Read more:

* [http://rubyjunky.com/rails-activerecord-serialize.html](http://rubyjunky.com/rails-activerecord-serialize.html)
* [http://blog.codeclimate.com/blog/2013/03/27/rails-insecure-defaults/](http://rubyjunky.com/rails-activerecord-serialize.html)
* [http://devblog.arnebrasseur.net/2014-02-yaml-syck-vs-psych](http://rubyjunky.com/rails-activerecord-serialize.html)
* [http://www.pauldix.net/2008/08/serializing-dat.html](http://rubyjunky.com/rails-activerecord-serialize.html)

