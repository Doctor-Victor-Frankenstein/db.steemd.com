class Post < ActiveRecord::Base
  #include Elasticsearch::Model
  #include Elasticsearch::Model::Callbacks

  self.primary_key = 'id'

  scope :root, -> { where(parent_id: 0) }

  def self.find_all_witness_updates
    root.where(category: %w{witness-category witness witnesses witness-catagory witness-catagory})
  end

end
