class CreateSpreeLocalTaxes < ActiveRecord::Migration
  def change
    create_table :spree_local_taxes do |t|
      t.string :zip
      t.string :county
      t.float :rate, :default => 0
      t.references :state
    end
  end
end
