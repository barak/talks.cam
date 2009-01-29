module SearchHelper
  def body_class
    "front #{@controller.action_name}"
  end
end
