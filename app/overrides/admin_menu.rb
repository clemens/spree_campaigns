Deface::Override.new(
  :virtual_path => "spree/layouts/admin",
  :name => "campaign_admin_tabs",
  :insert_bottom => "[data-hook='admin_tabs']",
  :text => "<%= tab(:campaigns, :url => spree.admin_campaigns_path) %>",
)
