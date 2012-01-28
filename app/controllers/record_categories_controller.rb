class RecordCategoriesController < ApplicationController
  skip_authorization_check :only => [:autocomplete_record_category_full_name]
  autocomplete :record_category, :full_name, :full => true
  respond_to :html, :json
  
  # GET /record_categories
  # GET /record_categories.xml
  def index
    authorize! :view_time, current_account
    @record_categories = current_account.record_categories.where('parent_id IS NULL').order('name')
    respond_with @record_categories
  end

  # GET /record_categories/1
  # GET /record_categories/1.xml
  def show
    authorize! :view_time, current_account
    @record_category = RecordCategory.find(params[:id])
    if html?
      if @record_category.list?
        @records = @record_category.tree_records.order('timestamp DESC').paginate :page => params[:page], :per_page => 10
      else
        @records = @record_category.records.order('timestamp DESC').paginate :page => params[:page], :per_page => 10
      end
    end
    respond_with @record_category
  end

  # GET /record_categories/new
  # GET /record_categories/new.xml
  def new
    authorize! :manage_account, current_account
    @record_category = RecordCategory.new
    @record_category.parent_id = params[:parent_id]
    @record_category.category_type = 'activity'
    @record_category.data = [{"key" => nil, "label" => nil, "type" => nil}]
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @record_category }
    end
  end

  # GET /record_categories/1/edit
  def edit
    authorize! :manage_account, current_account
    @record_category = current_account.record_categories.find(params[:id])
    if @record_category.category_type != 'list'
      @record_category.data ||= Array.new
      @record_category.data << {'key' => nil, 'label' => nil, 'type' => nil}
    end
      
  end

  # POST /record_categories
  # POST /record_categories.xml
  def create
    authorize! :manage_account, current_account
    @record_category = current_account.record_categories.new(params[:record_category])
    @record_category.data = Array.new
    respond_to do |format|
      if @record_category.save
        format.html { redirect_to(record_categories_path, :notice => 'Record category was successfully created.') }
        format.xml  { render :xml => @record_category, :status => :created, :location => @record_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @record_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /record_categories/1
  # PUT /record_categories/1.xml
  def update
    authorize! :manage_account, current_account
    @record_category = current_account.record_categories.find(params[:id])
    params[:record_category][:data].reject! { |x| x['key'].blank? } if params[:record_category][:data]
    respond_to do |format|
      if @record_category.update_attributes(params[:record_category])
        format.html { 
          logger.info @record_category.inspect
          redirect_to(@record_category, :notice => 'Record category was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @record_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /record_categories/1
  # DELETE /record_categories/1.xml
  def destroy
    authorize! :manage_account, current_account
    @record_category = current_account.record_categories.find(params[:id])
    @record_category.destroy

    respond_to do |format|
      format.html { redirect_to(record_categories_url) }
      format.xml  { head :ok }
    end
  end

  def track
    authorize! :manage_account, current_account
    @record_category = current_account.record_categories.find(params[:id])
    # Update the latest activity now that we know the ending timestamp
    now = Time.zone.now
    rec = current_account.records.create(:timestamp => now, :source => 'quantified awesome record categories', :source_id => @record_category.id, :record_category_id => @record_category.id)
    redirect_to edit_record_path(rec)
  end

  def bulk_update
    authorize! :manage_account, current_account
    params[:category_type].each do |k,v|
      cat = current_account.record_categories.find(k)
      cat.category_type = v
      cat.save!
    end
    if params[:commit] == t('records.index.recalculate_durations')
      Record.recalculate_durations(current_account)
      add_flash :notice, t('records.index.recalculated_durations')
    end
    go_to record_categories_path and return
  end

  def tree
    authorize! :manage_account, current_account
    @list = current_account.record_categories.order(:full_name)
    respond_with @list
  end

  def disambiguate
    authorize! :manage_account, current_account
    @list = RecordCategory.search(current_account, params[:category])
    if @list.nil?
      # No match
      go_to root_path, :error => "Could not find category matching: " + params[:category] and return
    elsif @list.is_a? RecordCategory
      # Just one, so track it directly
      redirect_to track_time_path(:timestamp => params[:timestamp], :source => params[:source], :destination => params[:destination]) and return
    end
    # Display the list
  end

  def get_autocomplete_items(parameters)
    super(parameters).where(:user_id => current_account.id)
  end
end
