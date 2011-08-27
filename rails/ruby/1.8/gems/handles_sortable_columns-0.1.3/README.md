
Sortable Table Columns
======================


Introduction
------------

A simple yet flexible Rails gem/plugin to quickly add sortable table columns to your controller and views.


Setup (Rails 3)
---------------

In your app's `Gemfile`, add:

    gem "handles_sortable_columns"

To install the gem with RDoc/ri documentation, do a:

    $ gem install handles_sortable_columns

Otherwise, do a `bundle install`.


Setup (Rails 2)
---------------

In your app's `config/environment.rb` add:

    config.gem "handles_sortable_columns"

To install the gem, do a:

    $ gem sources --add http://rubygems.org
    $ gem install handles_sortable_columns

, or use `rake gems:install`.


Basic Usage
-----------

Activate the feature in your controller class:

    class MyController < ApplicationController
      handles_sortable_columns
      ...

In a view, mark up sortable columns by using the <tt>sortable_column</tt> helper:

    <%= sortable_column "Product" %>
    <%= sortable_column "Price" %>

In controller action, fetch and use the order clause according to current state of sortable columns:

    def index
      order = sortable_column_order
      @records = Article.order(order)           # Rails 3.
      @records = Article.all(:order => order)   # Rails 2.
    end

That's it for basic usage. Production usage may require passing additional parameters to listed methods.


Production Usage
----------------

Please take time to read the gem's full [RDoc documentation](http://rdoc.info/projects/dadooda/handles_sortable_columns). This README has a limited coverage.


### Configuration ###

Change names of GET parameters used for sorting and pagination:

    class MyController < ApplicationController
      handles_sortable_columns do |conf|
        conf.sort_param = "s"
        conf.page_param = "p"
      end
      ...

Change CSS class of all sortable column `<a>` tags:

    handles_sortable_columns do |conf|
      conf.class = "SortableLink"
      conf.indicator_class = {:asc => "AscSortableLink", :desc => "DescSortableLink"}
    end

Change how text-based sort indicator looks like:

    handles_sortable_columns do |conf|
      conf.indicator_text = {:asc => "[asc]", :desc => "[desc]"}
    end

Disable text-based sort indicator completely:

    handles_sortable_columns do |conf|
      conf.indicator_text = {}
    end


### Helper Options ###

Explicitly specify column name:

    <%= sortable_column "Highest Price", :column => "max_price" %>

Specify CSS class for this particular link:

    <%= sortable_column "Name", :class => "SortableLink" %>

Specify sort direction on first click:

    <%= sortable_column "Created At", :direction => :asc %>


### Fetching Sort Order ###

To fetch sort order **securely**, with **column name validation**, **default values** and **multiple sort criteria**, use the block form of `sortable_column_order`:

    order = sortable_column_order do |column, direction|
      case column
      when "name"
        "#{column} #{direction}"
      when "created_at", "updated_at"
        "#{column} #{direction}, name ASC"
      else
        "name ASC"
      end
    end


Feedback
--------

Send bug reports, suggestions and criticisms through [project's page on GitHub](http://github.com/dadooda/handles_sortable_columns).
