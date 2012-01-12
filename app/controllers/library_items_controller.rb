class LibraryItemsController < ApplicationController
  handles_sortable_columns
  before_filter :authenticate_user!, :except => [:index, :show, :tag, :current]
  # GET /library_items
  # GET /library_items.xml
  def index
    authorize! :view_library_items, current_account
    params[:sort] ||= '-due'
    order = sortable_column_order
    if can? :manage_account, current_account
      @tags = current_account.library_items.tag_counts_on(:tags).sort_by(&:name)
      @library_items = current_account.library_items.order(order)
    else
      @tags = current_account.library_items.where('public=1').tag_counts_on(:tags).sort_by(&:name)
      @library_items = current_account.library_items.where('public=1').order(order)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @library_items }
    end
  end

  # GET /library_items/1
  # GET /library_items/1.xml
  def show
    @library_item = current_account.library_items.find(params[:id])
    authorize! :view, @library_item
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @library_item }
    end
  end

  # GET /library_items/new
  # GET /library_items/new.xml
  def new
    @library_item = current_account.library_items.new
    authorize! :create, LibraryItem

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @library_item }
    end
  end

  # GET /library_items/1/edit
  def edit
    @library_item = current_account.library_items.find(params[:id])
    authorize! :update, @library_item
    [:read_date, :status].each do |v|
      @library_item.send(v.to_s + '=', params[v]) if params[v]
    end
  end

  # POST /library_items
  # POST /library_items.xml
  def create
    authorize! :create, LibraryItem
    @library_item = current_account.library_items.new(params[:library_item])
    @library_item.user_id = current_account.id
    respond_to do |format|
      if @library_item.save
        format.html { redirect_to(@library_item, :notice => 'Library item was successfully created.') }
        format.xml  { render :xml => @library_item, :status => :created, :location => @library_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @library_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /library_items/1
  # PUT /library_items/1.xml
  def update
    @library_item = current_account.library_items.find(params[:id])
    authorize! :update, @library_item

    respond_to do |format|
      if @library_item.update_attributes(params[:library_item])
        format.html { redirect_to(:back, :notice => 'Library item was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @library_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /library_items/1
  # DELETE /library_items/1.xml
  def destroy
    @library_item = current_account.library_items.find(params[:id])
    authorize! :delete, @library_item
    @library_item.destroy

    respond_to do |format|
      format.html { redirect_to(library_items_url) }
      format.xml  { head :ok }
    end
  end

  def tag
    authorize! :view_library_items, current_account
    # Show by tags
    params[:sort] ||= '-due'
    order = filter_sortable_column_order %w{due title status}
    if can? :view_all, LibraryItem
      @tags = current_account.library_items.tag_counts_on(:tags).sort_by(&:name)
      @library_items = current_account.library_items.tagged_with(params[:id]).order(order)
    else
      @tags = current_account.library_items.where('public=1').tag_counts_on(:tags).sort_by(&:name)
      @library_items = current_account.library_items.where('public=1').tagged_with(params[:id]).order(order)
    end
    render :index
  end

  def bulk
    authorize :manage_account, current_account
    if params[:bulk] and params[:op] then
      params[:bulk].compact.each do |i|
        item = current_account.library_items.find(i)
        case params[:op]
          when 'Make public'
            item.public = true
          when 'Make private'
            item.public = false
          when 'Mark read'
            item.status = 'read'
            item.read_date ||= Date.today
        end
        item.save
      end
    end
    redirect_to :back and return
  end

  def current
    authorize! :view_library_items, current_account
    @library_items = current_account.library_items.where("(status = 'due' OR status IS NULL OR status = 'read')")
    if current_account != current_user
      @library_items = @library_items.where('public=1')
    end
    @tags = @library_items.tag_counts_on(:tags).sort_by(&:name)
    @library_items = @library_items.order(:due, :status)
  end
end
