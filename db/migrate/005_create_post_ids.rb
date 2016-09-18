class CreatePostIds < ActiveRecord::Migration
  def change
    create_table :post_ids do |t|

      # Id
      #t.integer :id,        null: false, limit: 5 #, options: 'PRIMARY KEY'
      t.integer :parent_id, null: false, limit: 4
      t.integer :block_id,  null: false, limit: 4

      # Header
      t.string  :author,    null: false, limit: 16
      t.string  :permlink,  null: false, limit: 255
      t.string  :category,  null: false, limit: 255

      #t.index :id, unique: true
      t.index :block_id
      t.index [:author, :permlink], unique: true
      t.index :category

    end
  end
end
