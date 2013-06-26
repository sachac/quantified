class TorontoLibrariesController < ApplicationController
  respond_to :html, :json, :xml, :csv
  def index
    @toronto_libraries = current_account.toronto_libraries
    authorize! :manage_account, current_account
    respond_with @toronto_libraries
  end

  def show
    @toronto_library = current_account.toronto_libraries.find(params[:id])
    authorize! :manage_account, current_account
    respond_with @toronto_library
  end

  def new
    @toronto_library = current_account.toronto_libraries.new
    authorize! :manage_account, current_account
    respond_with @toronto_library
  end

  def edit
    @toronto_library = current_account.toronto_libraries.find(params[:id])
    authorize! :manage_account, current_account
    respond_with @toronto_library
  end

  def create
    @toronto_library = current_account.toronto_libraries.new(params[:toronto_library])
    authorize! :manage_account, current_account
    @toronto_library.user = current_account
    if @toronto_library.save
      add_flash :notice, I18n.t('toronto_library.created')
      location = toronto_libraries_path
    end
    respond_with @toronto_library, location: location
  end

  # PUT /toronto_libraries/1
  # PUT /toronto_libraries/1.xml
  def update
    @toronto_library = current_account.toronto_libraries.find(params[:id])
    authorize! :manage_account, current_account
    if @toronto_library.update_attributes(params[:toronto_library])
      add_flash :notice, I18n.t('toronto_library.updated')
    end
    respond_with @toronto_library
  end

  def destroy
    @toronto_library = current_account.toronto_libraries.find(params[:id])
    authorize! :manage_account, current_account
    @toronto_library.destroy
    add_flash :notice, I18n.t('toronto_library.deleted')
    respond_with(@toronto_library, location: toronto_libraries_path)
  end

  def request_items
    @toronto_library = current_account.toronto_libraries.find(params[:id])
    @toronto_library.login
    authorize! :manage_account, current_account
    params[:items] ||= ''
    successes = Array.new
    errors = Array.new
    params[:items].scan(/[0-9]{14}/).each do |item|
      status = @toronto_library.request_item(item)
      if status
        successes << item
      else
        errors << item
      end
    end
    if successes.size > 0
      add_flash :notice, "Success: #{successes.join(', ')}"
    end
    if errors.size > 0
      add_flash :error, "Error: #{errors.join(', ')}"
    end
    @result = {success: successes, error: errors}
    respond_with @result, location: toronto_library_path(@toronto_library)
  end

  def refresh_all
    authorize! :manage_account, current_account
    result = Hash.new
    current_account.toronto_libraries.each do |l|
      result[l] = l.refresh_items
    end
    add_flash :notice, I18n.t('toronto_library.refresh')
    respond_with result, location: params[:destination] || request.env['HTTP_REFERER'] || root_path
  end
end
