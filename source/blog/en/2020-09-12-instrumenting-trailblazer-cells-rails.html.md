---

title: Instrumenting Trailblazer Cells::Rails
date: 2020-09-12 00:00 UTC
tags: 

---

In a recent project i am involved in, i had to perform some optimization regarding the overall application response time, and it happens this application is using Trailblazer Cells::Rails, or better known as [cells-rails](https://github.com/trailblazer/cells-rails). I have started to dig into the templates in an attempt to apply some [Russian doll caching](https://guides.rubyonrails.org/caching_with_rails.html#references), and at a first i have been a bit puzzled about the fact that my template was rendered inside the layout in about 227 ms, considering it was a fairly slim template.

Opening the view template in question, i have seen that it had 14 lines of code, and around 4 of those were part of each statement.

    <% SomeModel.published.for_scope(:homepage, organization: current_organization).each do |content_block| %>
      <% next unless content_block.manifest %>
      <%= cell content_block.manifest.cell, content_block %>
    <% end %>

I was intrigued about the fact that a cell helper appeared in my calls, yet, i could see how much time it was actually consumed in that cell. Diving into the code, I have seen the method was part of the rails-cells gem, which was part of my codebase.

Inspired by the ActionView’s instrumentation system, I have started to write a simple library, which in the end made use of the ActiveSupport::Notifications module to display all the calls that were made to that cell helper functions.

    module Cell
      module ViewModelInstrumenter

        def call(*)
          identifier = self.class.name.sub(/Cell$/, "").underscore
          instrument(:cell, identifier: identifier) do |_payload|
            Rails.logger.info("Start rendering #{identifier}")
            content = super
            Rails.logger.info("Finished rendering #{identifier}")
            content
          end
        end

        private

        def instrument(name, **options)
          ActiveSupport::Notifications.instrument("render_#{name}.action_view", options) do |payload|
            yield payload
          end
        end
      end
    end

Once i had the instrumenter code in place, i needed to make sure it was actually called, therefore i needed to update my initializer to make use of the new module.

    ::Cell::RailsExtensions::ViewModel.send(:include, ::Cell::ViewModelInstrumenter)

Once i had the call method in place, i needed also to make sure the events triggered are caught. Altering another initializer was the key, therefore, i have dropped the following config in it.

    ActiveSupport::Notifications.subscribe "render_cell.action_view" do |name, started, finished, unique_id, data|
      event = ActiveSupport::Notifications::Event.new(name, started, finished, unique_id, data)
      message = "Rendered cell #{event.payload[:identifier]} (#{event.duration.round(1)}ms)"
      Rails.logger.info(message)
    end

After restarting the application, i could see in my logs entries like:

    app | I, [2020-09-20T20:57:21.368665 #4696] INFO -- : Start rendering /author
    app | I, [2020-09-20T20:57:21.379692 #4696] INFO -- : Start rendering /follow_button
    app | I, [2020-09-20T20:57:21.385146 #4696] INFO -- : Finished rendering /follow_button
    app | I, [2020-09-20T20:57:21.385226 #4696] INFO -- : Rendered cell /follow_button (5.5ms)
    app | I, [2020-09-20T20:57:21.385369 #4696] INFO -- : Finished rendering /author
    app | I, [2020-09-20T20:57:21.385409 #4696] INFO -- : Rendered cell /author (16.7ms)

Now, having this kind of logging, helps me optimize and improve my existing code.
