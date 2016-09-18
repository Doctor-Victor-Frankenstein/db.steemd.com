class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes, :id => false do |t|

      #t.integer  :id, null: false, limit: 5, options: 'PRIMARY KEY'
      t.integer :voter_id, limit: 4
      t.integer :post_id,  limit: 4
      t.integer :weight,   limit: 3
      t.datetime :created

      t.index [:post_id, :created, :voter_id], unique: true
    end
  end
end
