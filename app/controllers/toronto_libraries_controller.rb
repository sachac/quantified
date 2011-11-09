class TorontoLibrariesController < ApplicationController
  # GET /toronto_libraries
  # GET /toronto_libraries.xml
  def index
    @toronto_libraries = TorontoLibrary.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @toronto_libraries }
    end
  end

  # GET /toronto_libraries/1
  # GET /toronto_libraries/1.xml
  def show
    @toronto_library = TorontoLibrary.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @toronto_library }
    end
  end

  # GET /toronto_libraries/new
  # GET /toronto_libraries/new.xml
  def new
    @toronto_library = TorontoLibrary.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @toronto_library }
    end
  end

  # GET /toronto_libraries/1/edit
  def edit
    @toronto_library = TorontoLibrary.find(params[:id])
  end

  # POST /toronto_libraries
  # POST /toronto_libraries.xml
  def create
    @toronto_library = TorontoLibrary.new(params[:toronto_library])
    @toronto_library.user = current_account
    respond_to do |format|
      if @toronto_library.save
        format.html { redirect_to(@toronto_library, :notice => 'Toronto library was successfully created.') }
        format.xml  { render :xml => @toronto_library, :status => :created, :location => @toronto_library }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @toronto_library.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /toronto_libraries/1
  # PUT /toronto_libraries/1.xml
  def update
    @toronto_library = TorontoLibrary.find(params[:id])

    respond_to do |format|
      if @toronto_library.update_attributes(params[:toronto_library])
        format.html { redirect_to(@toronto_library, :notice => 'Toronto library was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @toronto_library.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /toronto_libraries/1
  # DELETE /toronto_libraries/1.xml
  def destroy
    @toronto_library = TorontoLibrary.find(params[:id])
    @toronto_library.destroy

    respond_to do |format|
      format.html { redirect_to(toronto_libraries_url) }
      format.xml  { head :ok }
    end
  end
end
