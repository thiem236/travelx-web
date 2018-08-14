class ImageService
  attr_accessor  :image_params, :current_user

  def initialize(params,current_user)
    @current_user = current_user
    @image_params = params
  end

end