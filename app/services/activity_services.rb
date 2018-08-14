class ActivityServices
  attr_accessor  :activity_params, :current_user

  def initialize(params,current_user)
    @current_user = current_user
    @activity_params = params
  end

  def create_activity
    post = Post.find_by(created_by: @current_user.id, post_type: @activity_params[:activity_type],activity_id: @activity_params[:activity_id])
    if post.present?

      return "The #{map_test(@activity_params[:activity_type])} was previously shared"
    end
    resutl = get_object
    if resutl[:data].present?
      post = Post.create!(
          created_by: current_user.id,
          post_type: @activity_params[:activity_type],
          activity_type: convert_model(@activity_params[:activity_type]),
          activity_id:  @activity_params[:activity_id],
          obj: resutl[:data],
          total_like: resutl[:total_like],
          total_comment: resutl[:total_comment],
          user_may_see: resutl[:user_may_see]

      )
      return "Successful #{map_test(@activity_params[:activity_type])} sharing"
    else
      raise ArgumentError, "No parameters"
    end

  end

  def create_stamps
    resutl = get_stamp
    if resutl[:data].present?
      post = Post.create!(
          created_by: current_user.id,
          post_type: @activity_params[:activity_type],
          activity_type: convert_model(@activity_params[:activity_type]),
          stamp_ids:  resutl[:stamp_ids],
          obj: resutl[:data],
          total_like: resutl[:total_like],
          total_comment: resutl[:total_comment],
          user_may_see: resutl[:user_may_see],
          trip_id: resutl[:trip_id]

      )
      return "Successful #{map_test(@activity_params[:activity_type])} sharing"
    else
      raise ArgumentError, "No parameters"
    end
  end

  def update_activity(post)
    begin
      resutl = get_object
      if resutl && resutl[:data].present?
        post.update_attributes(
            obj: resutl[:data],
            total_like: resutl[:total_like],
            total_comment: resutl[:total_comment],
            user_may_see: resutl[:user_may_see],
            trip_id: resutl[:trip_id]
        )
      else
        post.destroy
      end

    rescue => e
      
    end

  end

  def get_object
    case @activity_params[:activity_type]
      when 'Image'
        get_image
      when 'Album'
        get_album
      when 'Country'
        get_trip
      when 'City'
        get_city
      when 'Stamp'
        get_stamp
    end
  end

  def convert_model(activity_type)
    case activity_type
      when 'Image'
        'Attachment'
      when 'City'
        'City'
      when 'Stamp'
        'PrivateStamp'
      else
        'Trip'
    end
  end

  def map_test(activity_type)
    case activity_type
      when 'Image'
        'photo'
      when 'City'
        'city'
      when 'Album'
        'Album'
      when 'Stamp'
        'Stamp'
      else
        'Trip'
    end
  end

  def get_stamp
    stamps = PrivateStamp.find(@activity_params[:stamp_ids])
    user_may_see = @current_user.friends.pluck(:id)

    {data:  stamps.map{|obj| StampSerializer.new(obj)}, total_like: 0, total_comment: 0,stamp_ids:stamps.map(&:id),user_may_see: user_may_see }
  end

  def get_image
    obj = Attachment.find(@activity_params[:activity_id])
    trip = obj.trip
    user_may_see = trip.user_trips.pluck(:user_id) << trip.created_by
    {
      data:  AttachmentSerializer.new(obj),
      total_like: obj.likes.length,
      total_comment: obj.comments.count,
      user_may_see: user_may_see,
      trip_id: trip.id
    }
  end

  def get_images(trip)
    images  = trip.attachments.with_type(:picture).order(uploaded_at: :desc).limit(10)
    images = images.map {|im| AttachmentSerializer.new(im)}
    user_may_see = trip.user_trips.pluck(:user_id) << trip.created_by
    total_like = trip.attachments.with_type(:picture).pluck(:likes).flatten.count
    total_count = Comment.where(comment_able_type: 'Attachment').
        where( "comment_able_id IN #{trip.attachments.with_type(:picture).select(:id).to_sql}").count
    {
        data: images,
      total_like: total_like,
      total_comment: total_count,
      user_may_see: user_may_see,
        trip_id: trip.id,
    }
  end


  def get_city

    city = City.find( @activity_params[:activity_id])
    trip = city.trip
    city.show_all
    city = CitySerializer.new(city)
    user_may_see = trip.user_trips.pluck(:user_id) << trip.created_by
    {data: city, total_like: city.like_num, total_comment: city.comment_num, user_may_see: user_may_see,trip_id: trip.id,}
  end

  def get_album
    trip = Trip.find(@activity_params[:activity_id])
    images  = trip.attachments.with_type(:picture).order(uploaded_at: :desc).limit(10)
    images = images.map {|im| AttachmentSerializer.new(im)}
    total_like = trip.attachments.with_type(:picture).pluck(:likes).flatten.count
    total_comment = Comment.where(comment_able_type: 'Attachment').
        where( "comment_able_id IN (#{trip.attachments.with_type(:picture).select(:id).to_sql})").count
    user_may_see = trip.user_trips.pluck(:user_id) << trip.created_by
    {data: images, total_like: total_like, total_comment: total_comment, user_may_see: user_may_see,trip_id: trip.id,}
  end

  def get_trip
    trip = Trip.find(@activity_params[:activity_id])
    user_may_see = trip.user_trips.pluck(:user_id) << trip.created_by
    {data: TripSerializer.new(trip), total_like: trip.total_like, total_comment: trip.total_comment,user_may_see: user_may_see,trip_id: trip.id,}
  end
end