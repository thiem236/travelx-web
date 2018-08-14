require 'active_support/concern'
module TripHelper
  def parse_time_string(time_string)
    time = case time_string
             when '24h'
               (Time.zone.now - 24.hours).to_f
             when '3d'
               (Time.zone.now - 3.days).to_f
             when '7d'
               (Time.zone.now - 7.days).to_f
             when '30d'
               (Time.zone.now - 30.days).to_f
             when '90d'
               (Time.zone.now - 90.days).to_f
             else
               Time.zone.now.to_f
           end
    time
  end

  def buid_condition(params_search)
    condition = []
    ping_params = []
    if params_search[:country]
      condition << "obj->>'country' = ?"
      ping_params <<  params_search[:country]
    end
    if params_search[:time]
      condition << "trips.end_date >= ?"
      ping_params <<  parse_time_string(params_search[:time])
    end
    if params_search[:friend_id]
      condition << "trips.created_by = ?"
      ping_params <<  params_search[:friend_id].to_i
    end
    if params_search[:show_image].to_i == 1
      condition << "trips.created_by = ?"
      ping_params <<  (params_search[:user_id] || current_user.id)

    end
    return condition, ping_params
  end

  def buid_trip_of_friend_condition(params_search)
    condition = []
    ping_params = []
    if params_search[:country]
      condition << "obj->>'country' = ?"
      ping_params <<  params_search[:country]
    end
    if params_search[:time]
      condition << "trips.end_date >= ?"
      ping_params <<  parse_time_string(params_search[:time])
    end
    return condition, ping_params
  end
end