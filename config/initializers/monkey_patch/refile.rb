module Refile
  class <<self
    def attachment_url(object, name, *args, host: nil, prefix: nil, filename: nil, format: nil)
      attacher = object.send(:"#{name}_attacher")
      file = attacher.get
      return unless file

      filename ||= attacher.basename || name.to_s
      format ||= attacher.extension
      host  ||= Rails.application.config.asset_host

      file_url(file, *args, host: host, prefix: prefix, filename: filename, format: format)
    end
  end
end