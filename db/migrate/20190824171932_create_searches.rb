class CreateSearches < ActiveRecord::Migration[5.2]
  def change
    create_table :searches do |t|
      t.string :query
      t.text :response

      t.timestamps
    end

    add_index :searches, :query, unique: true
  end
end
