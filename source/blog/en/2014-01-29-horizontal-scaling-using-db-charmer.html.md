---

title: Horizontal scaling using Db Charmer
date: 2014-01-29 00:00 UTC
tags: 
image: /uploads/dbcharmer.png
category: "Ruby on Rails" 

---

![Horizontal scaling using Db Charmer](/uploads/dbcharmer.png)

I was looking for a way to scale horizontally a Ruby on Rails application, and i have tried several methods to scale it. A method would be using a MySQL cluster, but that would require some serious database administrator skills, which unfortunately i don’t have.

dbreplication173Mainly i have an application that is read intensive (80% reads vs 20% writes) so, i have considered to use a MySQL master – slave configuration. The problem is that there is nothing about it in Rails documentation, however, after a short look in [ruby-toolbox.com](https://ruby-toolbox.com) I have discovered that I am not the only one who encountered this problem.

I have tried [octopus](https://github.com/tchandy/octopus) as my first choice, but i have soon discovered that is not fit for my application. For some reasons, not all my “read” queryes were passed to my slave connection. I have tried to see why, but because I was kind of pressed by time, i have dismissed this gem, even if i love the simplicity of the models.

After dismissing octopus, I have tried [db charmer](http://www.dbcharmer.net/) gem, which is pretty active. This is yet another Active Record Sharding gem that offers you the possibility to split database reads and writes.

The method i have chosen for my first try was to split my actions that were 100% reads, and push them to a slave. That was pretty simple using a before filter in my rails controllers.

    class ProfilesController < Application
      force_slave_reads :only =>  [ :show, :index ]
    end

This action allowed me to scale the application by keeping the same amount of servers, but the main effect was a drop in the response time of the applications.

The second action i have taken was to get all the heavy queries like counts out of the mysql master server and move them to slave.
    
    class User < ActiveRecord::Base
      def some_some_heavy_query
        self.on_slave.joins(:profile, :messages).count(:group => ['messages.thread_id'])
      end
    end

In my enthusiasm of having a mysql slave I have thought that it would be nice to have “ready” 3 slave instances in my config. I have later realised that this “optimisation” caused problems because those 3 connections multiplied by the number of max_child in my apache configuration and also multiplied by the number of the servers exceded the number of the max_connection on my mysql slave server.

After a small fix in my database.yml files I was back online with a more performant application.
