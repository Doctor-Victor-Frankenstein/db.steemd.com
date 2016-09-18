class PostId < ActiveRecord::Base

  @@map = {}

  def self.get_id(author, permlink, strict = true)
    return 0 if author == ''
    raise "No permlink supplied" if permlink == ''

    key = author + '/' + permlink
    return @@map[key] if @@map[key]

    sql = "SELECT id FROM post_ids WHERE author = '%s' AND permlink = '%s' LIMIT 1"
    id  = Generic.query_one(sql % [author, permlink])
    raise "POST NOT FOUND: #{key}" if strict && !id

    @@map[key] = id if id

    id
  end

end
