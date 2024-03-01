class CreateCafes < ActiveRecord::Migration[7.1]
  def change
    create_table :cafes do |t|
      t.string :title
      t.string :address
      t.string :gmaps_url
      t.string :picture
      t.jsonb :informations
      t.string :criteria, array: true

      t.timestamps
    end
  end
end
