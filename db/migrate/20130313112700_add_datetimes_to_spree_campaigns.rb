class AddDatetimesToSpreeCampaigns < ActiveRecord::Migration
  def up
    change_table :spree_campaigns do |t|
      t.datetime :starts_at, :ends_at
    end
  end

  def down
    change_table :spree_campaigns do |t|
      t.remove :starts_at, :ends_at
    end
  end
end
