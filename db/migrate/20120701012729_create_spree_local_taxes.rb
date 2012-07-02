class CreateSpreeLocalTaxes < ActiveRecord::Migration
  def change
    create_table :spree_local_taxes do |t|
      t.string :zip
      t.string :county
      t.float :rate
      t.references :state
    end
  end
end
