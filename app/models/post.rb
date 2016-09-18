class Post < ActiveRecord::Base

  scope :root, -> { where(parent_id: 0) }

  def self.find_all_witness_updates
    root.where(category: %w{witness-category witness witnesses witness-catagory witness-catagory})
  end

end
