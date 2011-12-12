class SessionsController < Devise::SessionsController
  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    respond_to do |format|  
      format.html { respond_with resource, :location => after_sign_in_path_for(resource) }  
      format.json {  
        return render :json => {  :success => true, 
           :user => resource
        } 
      }  
    end
  end
end
