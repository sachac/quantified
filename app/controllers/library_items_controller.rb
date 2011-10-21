class LibraryItemsController < ApplicationController
  # GET /library_items
  # GET /library_items.xml
  def index
    @library_items = LibraryItem.order('due DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @library_items }
    end
  end

  # GET /library_items/1
  # GET /library_items/1.xml
  def show
    @library_item = LibraryItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @library_item }
    end
  end

  # GET /library_items/new
  # GET /library_items/new.xml
  def new
    @library_item = LibraryItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @library_item }
    end
  end

  # GET /library_items/1/edit
  def edit
    @library_item = LibraryItem.find(params[:id])
  end

  # POST /library_items
  # POST /library_items.xml
  def create
    @library_item = LibraryItem.new(params[:library_item])

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
    @library_item = LibraryItem.find(params[:id])

    respond_to do |format|
      if @library_item.update_attributes(params[:library_item])
        format.html { redirect_to(@library_item, :notice => 'Library item was successfully updated.') }
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
    @library_item = LibraryItem.find(params[:id])
    @library_item.destroy

    respond_to do |format|
      format.html { redirect_to(library_items_url) }
      format.xml  { head :ok }
    end
  end
end
