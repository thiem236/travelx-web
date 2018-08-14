class TripImageServices
  attr_accessor :trip_image_params, :current_user, :page, :per_page, :trip
  def initialize(params)
    @current_user = params[:current_user]
    @trip_image_params = params[:trip_params]
    @page = @trip_image_params[:page] || 1
    @per_page = @trip_image_params[:per_page] || 20
    @trip = params[:trip]
  end

  def get_current_picture
    images = Attachment.images.where(able_type: 'Trip').
        where("able_id IN (#{Trip.select(:id).where(created_by: @current_user.id)})").
        page(@page).per(@per_page)
    {result: images, total_count: images.total_count, page: images.current_page, last_page: images.last_page?}
  end

  def get_friend_pictures
    images = Attachment.images.where(able_type: 'Trip').
        where("able_id IN (#{UserTrip.select(:trip_id).where(user_id: @current_user.id).to_sql})").
        page(@page).per(@per_page)
    {result: images, total_count: images.total_count, page: images.current_page, last_page: images.last_page?}
  end

  def upload_image
    @trip_image_params = trip_image_params
    time_upload = @trip_image_params[:uploaded_at].to_i
    ActiveRecord::Base.transaction do
      @city = City.find_or_initialize_by(
          name: @trip_image_params[:name].try(:strip) || 'Unknown',
          trip_id: @trip_image_params[:trip_id].to_i,
          country: @trip_image_params[:country].try(:strip) || 'Unknown'
      )
      @city.lat =  @trip_image_params[:lat]
      @city.long =  @trip_image_params[:long]
      @city.start_date ||= time_upload
      if @city.new_record?
        @city.start_date =  @trip_image_params[:uploaded_at]
        @city.end_date =  @trip_image_params[:uploaded_at].to_i + 24.hours.to_i
      else
        @city.start_date = time_upload > @city.start_date ? @city.start_date : time_upload
        @city.end_date = time_upload > @city.end_date.to_i ? time_upload : @city.end_date

      end
      @city.user_id =  @trip.created_by
      if @city.new_record?
        @city.upsert
      else
        @city.save!
      end
      attachemnt = @city.attachments.new(@trip_image_params[:attachments_attributes].first)
      @city.trip.update_trip_schedule
      attachemnt.save!
      @city.update_start_date_end_date
      attachemnt
    end

  end

  def edit_image
    @image = Attachment.find(@trip_image_params[:id])
    if @trip_image_params[:country_name].present?
      @trip_image_params[:country] = ISO3166::Country.find_country_by_name(@trip_image_params[:country_name]).alpha2
    end
    if @trip_image_params[:trip_id].present? && @trip_image_params[:trip_id].to_i != @image.trip_id

     @image = edit_image_trip_change
     @image.trip.update_trip_schedule
    else
     @image = edit_image_trip_no_change

    end
    trip = Trip.find(@image.trip_id)
    trip.update_trip_schedule
    @image
  end

  def edit_image_trip_no_change
    time_upload =  @trip_image_params[:uploaded_at].to_i > 0 ?  @trip_image_params[:uploaded_at].to_i : @image.uploaded_at
    ActiveRecord::Base.transaction do
      unless @trip_image_params[:city].nil?
        @city = City.find_or_initialize_by(
            name: @trip_image_params[:city].try(:strip) || 'Unknown',
            trip_id:@image.trip_id,
            country: @trip_image_params[:country].try(:strip)|| 'Unknown'
        )
      else
        @city = @image.able
      end

      @city.lat =  @trip_image_params[:lat].to_f if @trip_image_params[:lat].present?
      @city.long =  @trip_image_params[:long].to_f if @trip_image_params[:long].present?
      @city.start_date ||= time_upload
      if time_upload > 0
        if @city.new_record?
          @city.start_date = time_upload
          @city.end_date =  time_upload
        else
          @city.start_date = time_upload > @city.start_date ? @city.start_date : time_upload
          @city.end_date = time_upload > @city.start_date ? time_upload : @city.end_date
        end
      end
      @city.user_id =   @trip.created_by
      @city.save!
      @image.update_attributes!(image_param.merge(able_id: @city.id, able_type: 'City' ))

      @city.update_start_date_end_date
      @image
    end

  end

  def edit_image_trip_change
    time_upload =  @trip_image_params[:uploaded_at].to_i > 0 ?  @trip_image_params[:uploaded_at].to_i : @image.uploaded_at
    ActiveRecord::Base.transaction do
      trip = Trip.find(@trip_image_params[:trip_id])
      @city = City.find_or_initialize_by(
          name: @trip_image_params[:city].try(:strip)|| 'Unknown',
          trip_id:trip.id,
          country: @trip_image_params[:country].try(:strip)|| 'Unknown'
      )

      @city.lat =  @trip_image_params[:lat].to_f if @trip_image_params[:lat].present?
      @city.long =  @trip_image_params[:long].to_f if @trip_image_params[:long].present?

      @city.start_date ||= time_upload
      if time_upload > 0
        if @city.new_record?
          @city.start_date = time_upload
          @city.end_date =  time_upload
        else
          @city.start_date = time_upload > @city.start_date ? @city.start_date : time_upload
          @city.end_date = time_upload > @city.start_date ? time_upload : @city.end_date
        end
      end

      @city.user_id =   @trip.created_by
      @city.save!
      @image.update_attributes!(image_param.merge(able_id: @city.id, able_type: 'City' ))
      @city.update_start_date_end_date
      @image
    end

  end

  def trip_image_params
    @trip_image_params[:name] =  @trip_image_params[:city]
    @trip_image_params[:attachments_attributes] =  [
        file: @trip_image_params[:file],
        trip_id: @trip_image_params[:trip_id],
        uploaded_at:   @trip_image_params[:uploaded_at],
        caption: @trip_image_params[:caption],
        place: @trip_image_params[:item_name],
        place_type: @trip_image_params[:item_type],
        place_id: @trip_image_params[:item_id],
        lat: @trip_image_params[:lat],
        long: @trip_image_params[:long],
        upload_by: @current_user.id,
    ]
    if @trip_image_params[:country_name].present?
      @trip_image_params[:country] = ISO3166::Country.find_country_by_name(@trip_image_params[:country_name]).alpha2
    end
    @trip_image_params.permit(:country,
                              :item_type,
                              :item_name,
                              :name, :lat,
                              :trip_id, :long,
                              :uploaded_at,
                              :item_id,
                              attachments_attributes: [
                                  :location_id,
                                  :file,
                                  :uploaded_at,
                                  :trip_id,
                                  :caption,
                                  :place,
                                  :place_type,
                                  :place_id,
                                  :lat,
                                  :long,
                                  :upload_by
                              ]
    )
  end

  def image_param
    @trip_image_params[:place] = @trip_image_params[:item_name]
    @trip_image_params[:place_type] = @trip_image_params[:item_type]
    @trip_image_params[:place_id] = @trip_image_params[:item_id]
    @trip_image_params.permit(
                              :uploaded_at,
                              :caption,
                              :able_id,
                              :able_type,
                              :trip_id ,
                              :caption,
                              :place,
                              :place_type,
                              :place_id,
                              :lat,
                              :long,
                              :upload_by
    )
  end


end