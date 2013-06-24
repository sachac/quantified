class SessionsController < Devise::SessionsController
  def setup
    render json: {}, status: :not_found
  end

  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    # Confirm people who log in through Google or Facebook
    resource.confirm!
    sign_in(resource_name, resource)
    respond_to do |format|  
      format.html { go_to root_path and return }
      format.json {  
        return render :json => {  :success => true, 
           :user => resource
        } 
      }  
    end
  end
end
