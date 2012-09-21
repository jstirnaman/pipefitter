class CreateOclcs < ActiveRecord::Migration
  def change
    create_table :oclcs do |t|

      t.timestamps
    end
  end
end
