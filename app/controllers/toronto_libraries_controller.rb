class TorontoLibrariesController < ApplicationController
  # GET /toronto_libraries
  # GET /toronto_libraries.xml
  def index
    @toronto_libraries = current_account.toronto_libraries
    authorize! :manage_account, current_account

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @toronto_libraries }
    end
  end

  # GET /toronto_libraries/1
  # GET /toronto_libraries/1.xml
  def show
    @toronto_library = TorontoLibrary.find(params[:id])
    authorize! :manage_account, current_account

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @toronto_library }
    end
  end

  # GET /toronto_libraries/new
  # GET /toronto_libraries/new.xml
  def new
    @toronto_library = TorontoLibrary.new
    authorize! :manage_account, current_account

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @toronto_library }
    end
  end

  # GET /toronto_libraries/1/edit
  def edit
    @toronto_library = TorontoLibrary.find(params[:id])
    authorize! :manage_account, current_account
  end

  # POST /toronto_libraries
  # POST /toronto_libraries.xml
  def create
    @toronto_library = TorontoLibrary.new(params[:toronto_library])
    authorize! :manage_account, current_account
    @toronto_library.user = current_account
    respond_to do |format|
      if @toronto_library.save
        format.html { redirect_to(toronto_libraries_path, :notice => 'Library card was successfully created.') }
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
    authorize! :manage_account, current_account

    respond_to do |format|
      if @toronto_library.update_attributes(params[:toronto_library])
        format.html { redirect_to(@toronto_library, :notice => 'Library card was successfully updated.') }
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
    authorize! :manage_account, current_account
    @toronto_library.destroy

    respond_to do |format|
      format.html { redirect_to(toronto_libraries_url) }
      format.xml  { head :ok }
    end
  end

  def request_items
    @toronto_library = TorontoLibrary.find(params[:id])
    @toronto_library.login
    authorize! :manage_account, current_account
    params[:items] ||= ''
    success = Array.new
    error = Array.new
    params[:items].scan(/[0-9]{14}/).each do |item|
      if @toronto_library.request_item(item)
         success << item
      else
         error << item
      end
    end
    if success.size > 0
      add_flash :notice, "Success: #{success.join(', ')}"
    end
    if error.size > 0
      add_flash :error, "Error: #{error.join(', ')}"
    end
    redirect_to toronto_library_path(@toronto_library)
  end
end
