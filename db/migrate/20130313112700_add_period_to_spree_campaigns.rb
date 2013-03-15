class AddPeriodToSpreeCampaigns < ActiveRecord::Migration
  def up
    change_table :spree_campaigns do |t|
      t.datetime :starts_at, :ends_at
      t.integer :days
      t.string :period_mode
    end
  end

  def down
    change_table :spree_campaigns do |t|
      t.remove :starts_at, :ends_at, :days, :period_mode
    end
  end
end
