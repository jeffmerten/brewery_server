class CreateSearches < ActiveRecord::Migration[5.2]
  def change
    create_table :searches do |t|
      t.text :response
      t.float :radius
      t.st_point :lonlat, geographic: true

      t.timestamps
    end

    add_index :searches, :lonlat, using: :gist
  end
end
