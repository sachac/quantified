class StuffController < ApplicationController
  autocomplete :stuff, :name, :full => true
  skip_authorization_check :only => [:autocomplete_stuff_name]
  load_and_authorize_resource
  respond_to :html, :xml, :json, :csv
  handles_sortable_columns
  # GET /stuff
  # GET /stuff.xml
  def index
    params[:sort] ||= 'name'
    order = sortable_column_order do |column, direction|
      case column
      when "name"
        "lower(#{column}) #{direction}"
      when "created_at", "updated_at", "location_id", "in_place"
        "#{column} #{direction}, name ASC"
      else
        "lower(name) ASC"
      end
    end
    @stuff = current_account.stuff.order(order).includes(:location).where(:stuff_type => 'stuff')
    if params[:status] and params[:status] != 'all'
      @stuff = @stuff.where('status=?', params[:status])
    elsif params[:status] and params[:status] == 'all'
      @stuff = @stuff
    else
      @stuff = @stuff.where('status=? OR status IS NULL', 'active')
    end
    @contexts = current_account.contexts.order('name')
    respond_with @stuff
  end

  def bulk
    authorize! :manage_account, current_account
  end
  
  def bulk_update
    authorize! :manage_account, current_account
    if params[:location] and params[:batch]
      @response = Stuff.bulk_update(current_account, params[:location], params[:batch])
    end
    if @response
      if @response[:success].size > 0
        add_flash :notice, "Updated: " + @response[:success].map(&:name).join(', ')
      end
      if @response[:failure].size > 0
        add_flash :notice, "Failed: " + @response[:failure].join(', ')
      end
    end
    respond_with @response, :location => bulk_stuff_index_path
  end
  
  def log
    @stuff = Stuff.find_or_create(current_account, params[:stuff_name])
    @location = current_account.get_location(params[:location_name])
    @stuff.location = @location
    result = @stuff.save!
    redirect_to params[:destination] || stuff_index_path, :notice => (result ? 'Logged' : 'Problem?') and return
  end
  # GET /stuff/1
  # GET /stuff/1.xml
  def show
    @stuff = current_account.stuff.find(params[:id])
    @location_histories = @stuff.location_histories.order(:updated_at)
    respond_with @stuff
  end

  def history
    if request.format.html?
      redirect_to stuff_path(params[:id]) and return
    end
    @stuff = current_account.stuff.find(params[:id])
    @location_histories = @stuff.location_histories.order(:updated_at)
    respond_with @location_histories
  end
  # GET /stuff/new
  # GET /stuff/new.xml
  def new
    @stuff = current_account.stuff.new
    respond_with @stuff
  end

  # GET /stuff/1/edit
  def edit
    @stuff = current_account.stuff.find(params[:id])
    respond_with @stuff
  end

  # POST /stuff
  # POST /stuff.xml
  def create
    loc = nil
    if params[:stuff][:home_location_id] 
      loc = current_account.get_location(params[:stuff][:home_location_id])
      params[:stuff].delete(:home_location_id)
    end
    @stuff = current_account.stuff.new(params[:stuff])
    @stuff.home_location = loc
    @stuff.location = @stuff.home_location
    @stuff.user = current_account
    add_flash :notice => I18n.t('stuff.created') if @stuff.save
    respond_with @stuff
  end

  # PUT /stuff/1
  # PUT /stuff/1.xml
  def update
    @stuff = current_account.stuff.find(params[:id])
    # Change params[:stuff][:home_location]
    loc = nil
    if !params[:stuff][:home_location_id].blank?
      loc = current_account.get_location(params[:stuff][:home_location_id])
    end
    params[:stuff].delete(:home_location_id)
    params[:stuff].delete(:user_id)
    result = @stuff.update_attributes(params[:stuff])
    unless loc.blank? || !result
      @stuff.home_location = loc
      result = @stuff.save
    end
    add_flash :notice => I18n.t('stuff.updated') if result
    respond_with @stuff, :location => params[:destination] || stuff_path(@stuff)
  end

  # DELETE /stuff/1
  # DELETE /stuff/1.xml
  def destroy
    @stuff = current_account.stuff.find(params[:id])
    @stuff.destroy
    respond_with @stuff, :location => stuff_index_url
  end

  def get_autocomplete_items(parameters)
    puts parameters.inspect
    super(parameters).where(:user_id => current_account.id)
  end

end
