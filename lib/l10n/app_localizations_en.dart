// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get profileName => 'Andria';

  @override
  String get profileEmail => 'andria@email.com';

  @override
  String get appearance => 'APPEARANCE';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get systemDefault => 'System Default';

  @override
  String get defaultHomeView => 'Default Home View';

  @override
  String get today => 'Today';

  @override
  String get general => 'GENERAL';

  @override
  String get defaultReminderTime => 'Default Reminder Time';

  @override
  String get time0900am => '09:00 AM';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get account => 'ACCOUNT';

  @override
  String get logout => 'Logout';

  @override
  String get urdu => 'Urdu';

  @override
  String get week => 'Week';

  @override
  String get tasksCompletedLabel => 'Tasks Completed';

  @override
  String get onTimeRateLabel => 'On-Time Rate';

  @override
  String get currentStreakLabel => 'Current Streak';

  @override
  String get profile => 'Profile';

  @override
  String get fullName => 'Full Name';

  @override
  String get email => 'Email';

  @override
  String get productivityInsights => 'Productivity Insights';

  @override
  String tasksCompleted(int count) {
    return '$count Tasks Completed';
  }

  @override
  String onTimeRate(double percent) {
    return '$percent% On-Time Rate';
  }

  @override
  String currentStreak(int days) {
    return '$days Day Streak';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get clearAll => 'Clear All';

  @override
  String get noNotificationsTitle => 'You\'re all caught up!';

  @override
  String get noNotificationsSubtitle => 'No notifications right now';

  @override
  String get notificationsToday => 'Today';

  @override
  String get notificationsYesterday => 'Yesterday';

  @override
  String get notificationDueSoonTitle => 'Task Due Soon';

  @override
  String get notificationOverdueTitle => 'Overdue Task';

  @override
  String get notificationProductivityInsightTitle => 'Productivity Insight';

  @override
  String get notificationCollaborationTitle => 'New Tasks';

  @override
  String notificationDueSoonMessage(Object taskTitle, Object relativeTime) {
    return '$taskTitle Due at $relativeTime';
  }

  @override
  String notificationOverdueMessage(Object taskTitle, Object relativeTime) {
    return '$taskTitle at  $relativeTime ';
  }

  @override
  String notificationProductivityInsightMessage(Object completedCount) {
    return 'You completed $completedCount task(s) yesterday!';
  }

  @override
  String notificationCollaborationMessage(Object assignerName) {
    return '$assignerName assigned you a new task';
  }

  @override
  String get notificationSnoozeButton => 'Snooze';

  @override
  String get notificationMarkDoneButton => 'Mark as Done';

  @override
  String get notificationActivityTitle => 'New tasks';

  @override
  String get notificationActivityMessage => 'You created new tasks yesterday.';

  @override
  String get markAsDone => 'Mark as Done';

  @override
  String get snooze => 'Snooze';

  @override
  String get hi => 'Hi';

  @override
  String get showAll => 'Show All';

  @override
  String get filterAll => 'All';

  @override
  String get filterPersonal => 'Personal';

  @override
  String get filterWork => 'Work';

  @override
  String tasksForDay(Object day, Object date) {
    return '$day, $date';
  }

  @override
  String get noTasksForDay => 'No tasks for this day';

  @override
  String get bottomNavHome => 'Home';

  @override
  String get bottomNavCalendar => 'Calendar';

  @override
  String get bottomNavMe => 'Me';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String get filterTitleShow => 'Show';

  @override
  String get filterAllTasks => 'All (Today + Overdue + Upcoming)';

  @override
  String get filterOverdueTasks => 'Overdue Tasks';

  @override
  String get filterTodayTasks => 'Today Tasks';

  @override
  String get filterUpcomingTasks => 'Upcoming Tasks';

  @override
  String get filterCancelButton => 'Cancel';

  @override
  String get filterApplyButton => 'Apply';

  @override
  String get allTasks => 'All Tasks';

  @override
  String get noTasksForFilter => 'No tasks found for this filter.';

  @override
  String get deleteTaskTitle => 'Delete task?';

  @override
  String get deleteTaskMessage => 'Are you sure you want to delete this task?';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get deleteAction => 'Delete';

  @override
  String get editTaskTitle => 'Edit';

  @override
  String get newTaskTitle => 'New Task';

  @override
  String get saveAction => 'Save';

  @override
  String get taskTitleLabel => 'Task Title';

  @override
  String get taskTitleHint => 'e.g., Design the new dashboard';

  @override
  String get taskDescriptionLabel => 'Description';

  @override
  String get taskDescriptionHint => 'Add details about the task...';

  @override
  String get dueDateLabel => 'Due Date';

  @override
  String get timeLabel => 'Time';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get categoryLabel => 'Category';

  @override
  String get categoryWork => 'Work';

  @override
  String get recurringTaskLabel => 'Recurring Task';

  @override
  String get recurringTaskHint => 'Set task to repeat';

  @override
  String get subtasksLabel => 'Subtasks';

  @override
  String get subtasksProgressLabel => 'Progress';

  @override
  String subtasksCompletedStatus(Object completed, Object total) {
    return '$completed of $total Subtasks Completed';
  }

  @override
  String get addSubtaskAction => 'Add Subtask';

  @override
  String get enterSubTask => 'Enter Subtask';

  @override
  String get createTaskAction => 'Create Task';

  @override
  String get categoryPersonal => 'Personal';

  @override
  String get categoryCustom => 'Custom';

  @override
  String get enterCustomCategory => 'Enter custom category';

  @override
  String get updating => 'Updating...';

  @override
  String get creating => 'Creating...';

  @override
  String get updateTaskAction => 'Update Task';

  @override
  String get loginRequiredToAddTask => 'You must be logged in to add tasks';

  @override
  String get taskCreated => 'Task Created';

  @override
  String get taskUpdated => 'Task Updated';

  @override
  String get noSubtasksAdded => 'No subtasks added.';

  @override
  String get noDescriptionAdded => 'No description added.';

  @override
  String get taskDetails => 'Task Details';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get tasksFrom => 'Tasks from';

  @override
  String get tasksFor => 'Tasks for';

  @override
  String get tasksInThisRange => 'task(s) in this range';

  @override
  String get tasksForThisDay => 'task(s) for this day';

  @override
  String get noTasks => 'No tasks...';

  @override
  String get month => 'Month';

  @override
  String get addButton => 'Add';

  @override
  String get markAsCompleted => 'Mark as Completed';

  @override
  String get markAsIncomplete => 'Mark as Incomplete';

  @override
  String get exitAppTitle => 'Exit App';

  @override
  String get exitAppMessage => 'Are you sure you want to exit the app?';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get recurrenceRepeats => 'Repeats';

  @override
  String get recurrenceDaily => 'Daily';

  @override
  String get recurrenceWeekly => 'Weekly';

  @override
  String get recurrenceMonthly => 'Monthly';

  @override
  String get recurrenceYearly => 'Yearly';

  @override
  String get recurrenceEvery => 'every';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get recurrenceForever => 'Forever';

  @override
  String get recurrenceUntil => 'Until';

  @override
  String recurrenceForOccurrences(Object count) {
    return 'for $count Occurrences';
  }

  @override
  String get recurrenceCancel => 'Cancel';

  @override
  String get recurrenceSave => 'Save';

  @override
  String get recurrenceSetTitle => 'Set Recurrence';

  @override
  String get recurrenceDailyDesc => 'Repeats every day.';

  @override
  String get recurrenceMonthlyDesc => 'Repeats every month on this date.';

  @override
  String get recurrenceYearlyDesc => 'Repeats every year on this date.';

  @override
  String get recurrenceRepeatsOn => 'Repeats On';

  @override
  String get recurrenceEnds => 'Ends';

  @override
  String get recurrenceNever => 'Never';

  @override
  String get recurrenceOnDate => 'On Date';

  @override
  String get recurrenceAfterOccurrences => 'After N Occurrences';

  @override
  String get completedTasksText => 'Completed Tasks';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get logoutMessage => 'Are you sure you want to log out?';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get snackbar_message_title => 'Message';

  @override
  String get snackbar_message_body =>
      'This feature will be available in next update';

  @override
  String get selectTime => 'Select Time';

  @override
  String get selectDate => 'Select Date';

  @override
  String get date_format => 'MMM d, yyyy';

  @override
  String get time_format => 'hh:mm a';

  @override
  String get time_am => 'AM';

  @override
  String get time_pm => 'PM';

  @override
  String get overdueTask => 'Overdue Task';

  @override
  String get deleteRecurringEvent => 'Delete Recurring Task';

  @override
  String get recurringTaskDeletePrompt =>
      'This is a recurring task. What would you like to delete?';

  @override
  String get deleteOptionAllRecurrences => 'All Tasks';

  @override
  String get deleteOptionUpcomingRecurrences => 'This and following tasks';

  @override
  String get deleteOptionTodayTask => 'This task';
}
