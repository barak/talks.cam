namespace 'talks' do
  desc 'Manually update the related lists and related talks'
  task :update_relationships do
    require File.dirname(__FILE__) + '/../../config/environment'
    RelatedTalk.update_all_lists_and_talks
    RelatedList.update_all_lists_and_talks
  end
end