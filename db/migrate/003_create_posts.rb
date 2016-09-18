class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts, :id => false do |t|

      # Id
      t.integer :id,        null: false, limit: 5, options: 'PRIMARY KEY'
      t.integer :parent_id, null: false, limit: 4
      t.integer :children,  null: false, limit: 2
      t.integer :block,     null: false, limit: 4

      # Header
      t.string  :author,    null: false, limit: 16
      t.string  :permlink,  null: false, limit: 255
      t.string  :category,  null: false, limit: 255

      # Body
      t.text   :title,      null: false, limit: 1000
      t.text   :body,       null: false, limit: 16777215
      t.text   :json,       null: false, limit: 65535

      # Dates
      t.datetime :created,  null: false
      t.datetime :updated,  null: false
      t.datetime :active,   null: false
      t.datetime :paid,     null: true
      t.datetime :cashout,  null: true

      # Votes
      t.integer :net_rshares,           null: false
      t.integer :vote_rshares,          null: false
      t.integer :children_abs_rshares,  null: false
      t.float   :total_vote_weight,     null: false, limit: 53

      # Rewards
      t.integer :total_payout_value,         null: false, limit: 6
      t.integer :curator_payout_value,       null: false, limit: 6
      t.integer :pending_payout_value,       null: false, limit: 6
      t.integer :total_pending_payout_value, null: false, limit: 6


      t.index :id,   unique: true
      #t.index [:author, :permlink], unique: true
      t.index :created
      #t.index :category
    end
  end

  def migrate(direction)
    super
    if direction == :up
      #execute "ALTER TABLE posts MODIFY title VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
      #execute "ALTER TABLE posts MODIFY title TINYTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
      execute "ALTER TABLE posts MODIFY body MEDIUMTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL"
      execute "ALTER TABLE posts CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    end
  end
end
