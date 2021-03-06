module Behaveable
  module ResourceFinder
    # Get the behaveable object.
    #
    # ==== Returns
    # * <tt>ActiveRecord::Model</tt> - Behaveable instance object.
    def behaveable
      klass, param = behaveable_class
      klass.find(params[param.to_sym]) if klass
    end
    private

    # Lookup behaveable class.
    #
    # ==== Returns
    # * <tt>Response</tt> - Behaveable class or nil if not found.
    def behaveable_class
      params.each do |name|
        if name =~ /(.+)_id$/
          model = name.split('_')
          return model[0].classify.constantize, name
        end
      end
      nil
    end
  end
end