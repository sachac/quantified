class StuffController < ApplicationController
  load_and_authorize_resource
  handles_sortable_columns
  before_filter :no_sidebar
  def no_sidebar
    @skip_sidebar = true
  end
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
        "name DESC"
      end
    end
    @stuff = Stuff.where('status=?', 'active').order(order).includes(:location)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stuff }
    end
  end

  def log
    @stuff = Stuff.find(:first, :conditions => [ 'lower(name) = ?', params[:stuff_name].strip.downcase ])
    unless @stuff
      @stuff = Stuff.create(:name => params[:stuff_name].strip)
    end
    @location = Stuff.get_location(params[:location_name])
    @stuff.location = @location
    logger.info "Stuff: #{@stuff.id}"
    logger.info "Location: #{@location.id}"
    logger.info "New location: #{@stuff.location.id}"
    logger.info "New location: #{@stuff.location.id}"
    result = @stuff.save!
    redirect_to params[:destination] || stuff_index_path, :notice => (result ? 'Logged' : 'Problem?') and return
  end
  # GET /stuff/1
  # GET /stuff/1.xml
  def show
    @stuff = Stuff.find(params[:id])
    @location_histories = @stuff.location_histories.order(:updated_at)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @stuff }
    end
  end

  # GET /stuff/new
  # GET /stuff/new.xml
  def new
    @stuff = Stuff.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stuff }
    end
  end

  # GET /stuff/1/edit
  def edit
    @stuff = Stuff.find(params[:id])
  end

  # POST /stuff
  # POST /stuff.xml
  def create
    loc = nil
    if params[:stuff][:home_location_id] 
      loc = Stuff.get_location(params[:stuff][:home_location_id])
      params[:stuff].delete(:home_location_id)
    end
    @stuff = Stuff.new(params[:stuff])
    @stuff.home_location = loc
    @stuff.location = @stuff.home_location
    respond_to do |format|
      if @stuff.save
        format.html { redirect_to(@stuff, :notice => 'Stuff was successfully created.') }
        format.xml  { render :xml => @stuff, :status => :created, :location => @stuff }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @stuff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stuff/1
  # PUT /stuff/1.xml
  def update
    @stuff = Stuff.find(params[:id])
    # Change params[:stuff][:home_location]
    loc = nil
    if !params[:stuff][:home_location_id].blank?
      loc = Stuff.get_location(params[:stuff][:home_location_id])
    end
    params[:stuff].delete(:home_location_id)
    result = @stuff.update_attributes(params[:stuff])
    unless loc.blank? || !result
      @stuff.home_location = loc
      result = @stuff.save
    end
    respond_to do |format|
      if result
        format.html { redirect_to(params[:destination] || @stuff, :notice => 'Stuff was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stuff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stuff/1
  # DELETE /stuff/1.xml
  def destroy
    @stuff = Stuff.find(params[:id])
    @stuff.destroy

    respond_to do |format|
      format.html { redirect_to(stuff_index_url) }
      format.xml  { head :ok }
    end
  end
end
