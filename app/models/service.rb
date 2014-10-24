class Service < ActiveRecord::Base
  belongs_to :user
  private
  def service_params
    params.require(:provider, :uid, :uname, :uemail)
  end
end
