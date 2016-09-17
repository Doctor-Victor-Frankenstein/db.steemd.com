class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks, :id => false do |t|
      t.integer  :id, null: false, limit: 5, options: 'PRIMARY KEY'
      t.string   :witness, limit: 16
      t.integer  :txs, limit: 3
      t.datetime :signed_at

      t.index :id, unique: true
      t.index [:witness, :id]
      t.index [:signed_at, :id]
    end
  end
end
