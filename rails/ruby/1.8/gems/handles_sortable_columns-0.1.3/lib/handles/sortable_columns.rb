module Handles  #:nodoc:
  # == Overview
  #
  # A sortable columns feature for your controller and views.
  #
  # == Basic Usage
  #
  # Activate the feature in your controller class:
  #
  #   class MyController < ApplicationController
  #     handles_sortable_columns
  #     ...
  # 
  # In a view, mark up sortable columns by using the <tt>sortable_column</tt> helper:
  #
  #   <%= sortable_column "Product" %>
  #   <%= sortable_column "Price" % >
  #
  # In controller action, fetch and use the order clause according to current state of sortable columns:
  #
  #   def index
  #     order = sortable_column_order
  #     @records = Article.order(order)           # Rails 3.
  #     @records = Article.all(:order => order)   # Rails 2.
  #   end
  #
  # That's it for basic usage. Production usage may require passing additional parameters to listed methods.
  #
  # See also:
  # * MetaClassMethods#handles_sortable_columns
  # * InstanceMethods#sortable_column_order
  module SortableColumns
    def self.included(owner)    #:nodoc:
      owner.extend MetaClassMethods
    end

    # Sortable columns configuration object. Passed to the block when you do a:
    #
    #   handles_sortable_columns do |conf|
    #     ...
    #   end
    class Config
      # CSS class for link (regardless of sorted state). Default:
      #
      #   SortableColumnLink
      attr_accessor :link_class

      # GET parameter name for page number. Default:
      #
      #   page
      attr_accessor :page_param

      # GET parameter name for sort column and direction. Default:
      #
      #   sort
      attr_accessor :sort_param

      # Sort indicator text. If any of values are empty, indicator is not displayed. Default:
      #
      #  {:asc => "&nbsp;&darr;&nbsp;", :desc => "&nbsp;&uarr;&nbsp;"}
      attr_accessor :indicator_text

      # Sort indicator class. Default:
      #
      #  {:asc => "SortedAsc", :desc => "SortedDesc"}
      attr_accessor :indicator_class

      def initialize(attrs = {})
        defaults = {
          :link_class => "SortableColumnLink",
          :indicator_class => {:asc => "SortedAsc", :desc => "SortedDesc"},
          :indicator_text => {:asc => "&nbsp;&darr;&nbsp;", :desc => "&nbsp;&uarr;&nbsp;"},
          :page_param => "page",
          :sort_param => "sort",
        }

        defaults.merge(attrs).each {|k, v| send("#{k}=", v)}
      end

      # Bracket access for convenience.
      def [](key)
        send(key)
      end

      # Bracket access for convenience.
      def []=(key, value)
        send("#{key}=", value)
      end
    end # Config

    module MetaClassMethods
      # Activate and optionally configure the sortable columns feature in your controller.
      #
      #   class MyController < ApplicationController
      #     handles_sortable_columns
      #     ...
      #
      # With configuration:
      #
      #   class MyController < ApplicationController
      #     handles_sortable_columns do |conf|
      #       conf.sort_param = "s"
      #       conf.page_param = "p"
      #       conf.indicator_text = {}
      #       ...
      #     end
      #     ...
      #
      # With filter options:
      #
      #   class MyController < ApplicationController
      #     handles_sortable_columns(:only => [:index]) do |conf|
      #       ...
      #     end
      #     ...
      #
      # NOTE: <tt>conf</tt> is a Config object.
      def handles_sortable_columns(fopts = {}, &block)
        # Multiple activation protection.
        if not self < InstanceMethods
          include InstanceMethods
          helper_method :sortable_column
        end

        # Process configuration at every activation.
        before_filter(fopts) do |ac|
          ac.instance_eval do
            # NOTE: Can't `yield`, we're in a block already.
            block.call(sortable_columns_config) if block
          end
        end
      end
    end # MetaClassMethods

    module InstanceMethods
      private

      # Internal/advanced use only. Parse sortable column sort param into a Hash with predefined keys.
      #
      #   parse_sortable_column_sort_param("name")    # => {:column => "name", :direction => :asc}
      #   parse_sortable_column_sort_param("-name")   # => {:column => "name", :direction => :desc}
      #   parse_sortable_column_sort_param("")        # => {:column => nil, :direction => nil}
      def parse_sortable_column_sort_param(sort)    #:nodoc:
        out = {:column => nil, :direction => nil}
        if sort.to_s.strip.match /\A((?:-|))([^-]+)\z/
          out[:direction] = $1.empty?? :asc : :desc
          out[:column] = $2.strip
        end
        out
      end

      # Render a sortable column link.
      #
      # Options:
      #
      # * <tt>:column</tt> -- Column name. E.g. <tt>created_at</tt>.
      # * <tt>:direction</tt> -- Sort direction on first click. <tt>:asc</tt> or <tt>:desc</tt>. Default is <tt>:asc</tt>.
      # * <tt>:link_class</tt> -- CSS class for link, regardless of sorted state.
      # * <tt>:link_style</tt> -- CSS style for link, regardless of sorted state.
      #
      # Examples:
      #
      #   <%= sortable_column "Product" %>
      #   <%= sortable_column "Highest Price", :column => "max_price" %>
      #   <%= sortable_column "Name", :link_class => "SortableLink" %>
      #   <%= sortable_column "Created At", :direction => :asc %>
      def sortable_column(title, options = {})    #:doc:
        options = options.dup
        o = {}
        conf = {}
        conf[k = :sort_param] = sortable_columns_config[k]
        conf[k = :page_param] = sortable_columns_config[k]
        conf[k = :indicator_text] = sortable_columns_config[k]
        conf[k = :indicator_class] = sortable_columns_config[k]

        #HELP sortable_column
        o[k = :column] = options.delete(k) || sortable_column_title_to_name(title)
        o[k = :direction] = options.delete(k).to_s.downcase =~ /\Adesc\z/ ? :desc : :asc
        o[k = :link_class] = options.delete(k) || sortable_columns_config[k]
        o[k = :link_style] = options.delete(k)
        #HELP /sortable_column

        raise "Unknown option(s): #{options.inspect}" if not options.empty?

        # Parse sort param.
        pp = parse_sortable_column_sort_param(params[conf[:sort_param]])

        css_class = []
        if (s = o[:link_class]).present?
          css_class << s
        end

        # If already sorted and indicator class defined, append it.
        if pp[:column] == o[:column].to_s and (s = conf[:indicator_class][pp[:direction]]).present?
          css_class << s
        end

        # Build link itself.
        pcs = []

        html_options = {}
        html_options[:class] = css_class.join(" ") if css_class.present?
        html_options[:style] = o[:link_style] if o[:link_style].present?

        # Rails 3 / Rails 2 fork.
        tpl = respond_to?(:view_context) ? view_context : @template

        # Already sorted?
        if pp[:column] == o[:column].to_s
          pcs << tpl.link_to(title, params.merge({conf[:sort_param] => [("-" if pp[:direction] == :asc), o[:column]].join, conf[:page_param] => 1}), html_options)       # Opposite sort order when clicked.

          # Append indicator, if configured.
          if (s = conf[:indicator_text][pp[:direction]]).present?
            pcs << s
          end
        else
          # Not sorted.
          pcs << tpl.link_to(title, params.merge({conf[:sort_param] => [("-" if o[:direction] != :asc), o[:column]].join, conf[:page_param] => 1}), html_options)
        end

        # For Rails 3 provide #html_safe.
        (v = pcs.join).respond_to?(:html_safe) ? v.html_safe : v
      end

      # Compile SQL order clause according to current state of sortable columns.
      #
      # Basic (kickstart) usage:
      #
      #   order = sortable_column_order
      #
      # <b>WARNING:</b> Basic usage is <b>not recommended</b> for production since it is potentially
      # vulnerable to SQL injection!
      #
      # Production usage with multiple sort criteria, column name validation and defaults:
      #
      #   order = sortable_column_order do |column, direction|
      #     case column
      #     when "name"
      #       "#{column} #{direction}"
      #     when "created_at", "updated_at"
      #       "#{column} #{direction}, name ASC"
      #     else
      #       "name ASC"
      #     end
      #   end
      #
      # Apply order:
      #
      #   @records = Article.order(order)           # Rails 3.
      #   @records = Article.all(:order => order)   # Rails 2.
      def sortable_column_order(&block)
        conf = {}
        conf[k = :sort_param] = sortable_columns_config[k]

        # Parse sort param.
        pp = parse_sortable_column_sort_param(params[conf[:sort_param]])

        order = if block
          column, direction = pp[:column], pp[:direction]
          yield(column, direction)    # NOTE: Makes RDoc/ri look a little smarter.
        else
          # No block -- do a straight mapping.
          if pp[:column]
            [pp[:column], pp[:direction]].join(" ")
          end
        end

        # Can be nil.
        order
      end

      # Internal use only. Convert title to sortable column name.
      #
      #   sortable_column_title_to_name("ProductName")  # => "product_name"
      def sortable_column_title_to_name(title)    #:nodoc:
        title.gsub(/(\s)(\S)/) {$2.upcase}.underscore
      end

      # Internal use only. Access/initialize feature's config.
      def sortable_columns_config   #:nodoc:
        @sortable_columns_config ||= ::Handles::SortableColumns::Config.new
      end
    end # InstanceMethods
  end # SortableColumns
end # Handles
