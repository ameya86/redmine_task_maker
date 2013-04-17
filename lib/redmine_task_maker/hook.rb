module RedmineTaskMaker
  class Hook < Redmine::Hook::ViewListener
  render_on :view_issues_new_top, :partial => 'task_maker/issues_new_top'
  render_on :view_issues_form_details_bottom, :partial => 'task_maker/issues_form_details_bottom'

    # チケットの新規作成時
    def controller_issues_new_after_save(context = {})
      create_tasks(context[:issue], context[:params] && context[:params][:issue] && context[:params][:issue][:tasks])
    end

    # タスクを子チケットとして作成する
    def create_tasks(parent_issue, tasks)
      # 引数が不足
      return if parent_issue.nil? || tasks.blank? || tasks[:subject].blank?

      # チケットを元にタスク（子チケット）を作成する
      task_count = tasks[:subject].length
      task_count.times do |task_number|
        # 題名が空の列はスキップ
        next if tasks[:subject][task_number].blank?

        task = copy_issue(parent_issue)
        task.subject =  tasks[:subject][task_number]
        task.assigned_to_id = tasks[:assigned_to_id][task_number]
        task.save
      end
    end

    # 進捗や時間系以外をコピー
    def copy_issue(issue)
      task = Issue.new
      task.tracker_id = issue.tracker_id
      task.priority_id = issue.priority_id
      task.project_id = issue.project_id
      task.author_id = issue.author_id
      task.parent_issue_id = issue.id
      task.category_id = issue.category_id
      task.fixed_version_id = issue.fixed_version_id
      return task
    end
  end
end
