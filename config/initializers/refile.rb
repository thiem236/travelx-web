require "refile/s3"
unless  Rails.env == 'development'
  aws = {
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SERCET_KEY_ID"],
      region: "ap-southeast-1",
      bucket: "tralvelx-app",
  }
  Refile.cache = Refile::S3.new(prefix: "cache", **aws)
  Refile.store = Refile::S3.new(prefix: "store", **aws)
else
  Refile.store = Refile::Backend::FileSystem.new(Rails.root.join('public/uploads/refile_store').to_s)
end