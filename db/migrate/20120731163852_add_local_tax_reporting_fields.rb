class AddLocalTaxReportingFields < ActiveRecord::Migration
  def change
    rename_column :spree_local_taxes, :county, :city
    rename_column :spree_local_taxes, :rate, :local
    add_column :spree_local_taxes, :other, :float, :default => 0.0
    add_column :spree_states, :tax, :float, :default => 0.0
  end
end
