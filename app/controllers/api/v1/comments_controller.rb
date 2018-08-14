class Api::V1::CommentsController < Api::ApiController
  include Behaveable::ResourceFinder
  swagger_controller  :comments, 'CommentsController'

  # GET /attachments
  def index
    @attachments = Attachment.all
  end

  # GET /attachments/1
  def show
  end

  # GET /attachments/new
  def new
    @attachment = Attachment.new
  end

  # GET /attachments/1/edit
  def edit
  end

  # POST /attachments
  swagger_api :create do
    summary "Create new  File"
    Api::ApiController.add_common_params(self)
    param :path, :city_id, :integer, :require, 'Post id or ... '
    param :form, :user_id, :integer, :require, 'User comment '
    param :form, :content, :string, :require, 'content comment '

  end
  def create
    begin
      able_model = behaveable
      @comment = able_model.comments.new(comment_params)
      @comment.save
      respond_without_location(@comment, 201)
    rescue => e
      raise e
      respond_error e.message
    end
  end

  # PATCH/PUT /attachments/1
  def update
    if @attachment.update(attachment_params)
      redirect_to @attachment, notice: 'Attachment was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /attachments/1
  def destroy
    @attachment.destroy
    redirect_to attachments_url, notice: 'Attachment was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attachment
      @attachment = Attachment.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
  def comment_params
    params.permit(:user_id, :content)
  end
end
