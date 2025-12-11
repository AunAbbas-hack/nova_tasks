import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Andria'**
  String get profileName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'andria@email.com'**
  String get profileEmail;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @defaultHomeView.
  ///
  /// In en, this message translates to:
  /// **'Default Home View'**
  String get defaultHomeView;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'GENERAL'**
  String get general;

  /// No description provided for @defaultReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Default Reminder Time'**
  String get defaultReminderTime;

  /// No description provided for @time0900am.
  ///
  /// In en, this message translates to:
  /// **'09:00 AM'**
  String get time0900am;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get account;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @urdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get urdu;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @tasksCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Tasks Completed'**
  String get tasksCompletedLabel;

  /// No description provided for @onTimeRateLabel.
  ///
  /// In en, this message translates to:
  /// **'On-Time Rate'**
  String get onTimeRateLabel;

  /// No description provided for @currentStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreakLabel;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @productivityInsights.
  ///
  /// In en, this message translates to:
  /// **'Productivity Insights'**
  String get productivityInsights;

  /// Shows number of completed tasks
  ///
  /// In en, this message translates to:
  /// **'{count} Tasks Completed'**
  String tasksCompleted(int count);

  /// Shows percentage of on-time rate
  ///
  /// In en, this message translates to:
  /// **'{percent}% On-Time Rate'**
  String onTimeRate(double percent);

  /// Shows current streak in days
  ///
  /// In en, this message translates to:
  /// **'{days} Day Streak'**
  String currentStreak(int days);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @noNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get noNotificationsTitle;

  /// No description provided for @noNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications right now'**
  String get noNotificationsSubtitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get notificationsClearAll;

  /// No description provided for @notificationsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notificationsToday;

  /// No description provided for @notificationsYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notificationsYesterday;

  /// No description provided for @notificationDueSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Due Soon'**
  String get notificationDueSoonTitle;

  /// No description provided for @notificationOverdueTitle.
  ///
  /// In en, this message translates to:
  /// **'Overdue Task'**
  String get notificationOverdueTitle;

  /// No description provided for @notificationProductivityInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'Productivity Insight'**
  String get notificationProductivityInsightTitle;

  /// No description provided for @notificationCollaborationTitle.
  ///
  /// In en, this message translates to:
  /// **'New Tasks'**
  String get notificationCollaborationTitle;

  /// Shown when a task is due soon
  ///
  /// In en, this message translates to:
  /// **'{taskTitle} Due at {relativeTime}'**
  String notificationDueSoonMessage(Object taskTitle, Object relativeTime);

  /// Shown when a task is overdue
  ///
  /// In en, this message translates to:
  /// **'{taskTitle} at  {relativeTime} '**
  String notificationOverdueMessage(Object taskTitle, Object relativeTime);

  /// Yesterday productivity summary
  ///
  /// In en, this message translates to:
  /// **'You completed {completedCount} task(s) yesterday!'**
  String notificationProductivityInsightMessage(Object completedCount);

  /// New task assigned by someone
  ///
  /// In en, this message translates to:
  /// **'{assignerName} assigned you a new task'**
  String notificationCollaborationMessage(Object assignerName);

  /// No description provided for @notificationSnoozeButton.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get notificationSnoozeButton;

  /// No description provided for @notificationMarkDoneButton.
  ///
  /// In en, this message translates to:
  /// **'Mark as Done'**
  String get notificationMarkDoneButton;

  /// No description provided for @notificationActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'New tasks'**
  String get notificationActivityTitle;

  /// No description provided for @notificationActivityMessage.
  ///
  /// In en, this message translates to:
  /// **'You created new tasks yesterday.'**
  String get notificationActivityMessage;

  /// No description provided for @markAsDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as Done'**
  String get markAsDone;

  /// No description provided for @snooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get snooze;

  /// No description provided for @hi.
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get hi;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get showAll;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get filterPersonal;

  /// No description provided for @filterWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get filterWork;

  /// No description provided for @tasksForDay.
  ///
  /// In en, this message translates to:
  /// **'{day}, {date}'**
  String tasksForDay(Object day, Object date);

  /// No description provided for @noTasksForDay.
  ///
  /// In en, this message translates to:
  /// **'No tasks for this day'**
  String get noTasksForDay;

  /// No description provided for @bottomNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomNavHome;

  /// No description provided for @bottomNavCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get bottomNavCalendar;

  /// No description provided for @bottomNavMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get bottomNavMe;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySun;

  /// No description provided for @filterTitleShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get filterTitleShow;

  /// No description provided for @filterAllTasks.
  ///
  /// In en, this message translates to:
  /// **'All (Today + Overdue + Upcoming)'**
  String get filterAllTasks;

  /// No description provided for @filterOverdueTasks.
  ///
  /// In en, this message translates to:
  /// **'Overdue Tasks'**
  String get filterOverdueTasks;

  /// No description provided for @filterTodayTasks.
  ///
  /// In en, this message translates to:
  /// **'Today Tasks'**
  String get filterTodayTasks;

  /// No description provided for @filterUpcomingTasks.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Tasks'**
  String get filterUpcomingTasks;

  /// No description provided for @filterCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get filterCancelButton;

  /// No description provided for @filterApplyButton.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get filterApplyButton;

  /// No description provided for @allTasks.
  ///
  /// In en, this message translates to:
  /// **'All Tasks'**
  String get allTasks;

  /// No description provided for @noTasksForFilter.
  ///
  /// In en, this message translates to:
  /// **'No tasks found for this filter.'**
  String get noTasksForFilter;

  /// No description provided for @deleteTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete task?'**
  String get deleteTaskTitle;

  /// No description provided for @deleteTaskMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this task?'**
  String get deleteTaskMessage;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @editTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editTaskTitle;

  /// No description provided for @newTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get newTaskTitle;

  /// No description provided for @saveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// No description provided for @taskTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get taskTitleLabel;

  /// No description provided for @taskTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Design the new dashboard'**
  String get taskTitleHint;

  /// No description provided for @taskDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get taskDescriptionLabel;

  /// No description provided for @taskDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add details about the task...'**
  String get taskDescriptionHint;

  /// No description provided for @dueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityLabel;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get priorityUrgent;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @categoryWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get categoryWork;

  /// No description provided for @recurringTaskLabel.
  ///
  /// In en, this message translates to:
  /// **'Recurring Task'**
  String get recurringTaskLabel;

  /// No description provided for @recurringTaskHint.
  ///
  /// In en, this message translates to:
  /// **'Set task to repeat'**
  String get recurringTaskHint;

  /// No description provided for @subtasksLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get subtasksLabel;

  /// No description provided for @subtasksProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get subtasksProgressLabel;

  /// No description provided for @subtasksCompletedStatus.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} Completed'**
  String subtasksCompletedStatus(Object completed, Object total);

  /// No description provided for @addSubtaskAction.
  ///
  /// In en, this message translates to:
  /// **'Add Subtask'**
  String get addSubtaskAction;

  /// No description provided for @enterSubTask.
  ///
  /// In en, this message translates to:
  /// **'Enter Subtask'**
  String get enterSubTask;

  /// No description provided for @createTaskAction.
  ///
  /// In en, this message translates to:
  /// **'Create Task'**
  String get createTaskAction;

  /// No description provided for @categoryPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get categoryPersonal;

  /// No description provided for @categoryCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get categoryCustom;

  /// No description provided for @enterCustomCategory.
  ///
  /// In en, this message translates to:
  /// **'Enter custom category'**
  String get enterCustomCategory;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// No description provided for @updateTaskAction.
  ///
  /// In en, this message translates to:
  /// **'Update Task'**
  String get updateTaskAction;

  /// No description provided for @loginRequiredToAddTask.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to add tasks'**
  String get loginRequiredToAddTask;

  /// No description provided for @taskCreated.
  ///
  /// In en, this message translates to:
  /// **'Task Created'**
  String get taskCreated;

  /// No description provided for @taskUpdated.
  ///
  /// In en, this message translates to:
  /// **'Task Updated'**
  String get taskUpdated;

  /// No description provided for @noSubtasksAdded.
  ///
  /// In en, this message translates to:
  /// **'No subtasks added.'**
  String get noSubtasksAdded;

  /// No description provided for @noDescriptionAdded.
  ///
  /// In en, this message translates to:
  /// **'No description added.'**
  String get noDescriptionAdded;

  /// No description provided for @taskDetails.
  ///
  /// In en, this message translates to:
  /// **'Task Details'**
  String get taskDetails;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @tasksFrom.
  ///
  /// In en, this message translates to:
  /// **'Tasks from'**
  String get tasksFrom;

  /// No description provided for @tasksFor.
  ///
  /// In en, this message translates to:
  /// **'Tasks for'**
  String get tasksFor;

  /// No description provided for @tasksInThisRange.
  ///
  /// In en, this message translates to:
  /// **'task(s) in this range'**
  String get tasksInThisRange;

  /// No description provided for @tasksForThisDay.
  ///
  /// In en, this message translates to:
  /// **'task(s) for this day'**
  String get tasksForThisDay;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks...'**
  String get noTasks;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @markAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as Completed'**
  String get markAsCompleted;

  /// No description provided for @markAsIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as Incomplete'**
  String get markAsIncomplete;

  /// No description provided for @exitAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exitAppTitle;

  /// No description provided for @exitAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the app?'**
  String get exitAppMessage;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @recurrenceRepeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get recurrenceRepeats;

  /// No description provided for @recurrenceDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get recurrenceDaily;

  /// No description provided for @recurrenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get recurrenceWeekly;

  /// No description provided for @recurrenceMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get recurrenceMonthly;

  /// No description provided for @recurrenceYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get recurrenceYearly;

  /// No description provided for @recurrenceEvery.
  ///
  /// In en, this message translates to:
  /// **'every'**
  String get recurrenceEvery;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @recurrenceForever.
  ///
  /// In en, this message translates to:
  /// **'forever'**
  String get recurrenceForever;

  /// No description provided for @recurrenceUntil.
  ///
  /// In en, this message translates to:
  /// **'until'**
  String get recurrenceUntil;

  /// No description provided for @recurrenceForOccurrences.
  ///
  /// In en, this message translates to:
  /// **'for {count} occurrences'**
  String recurrenceForOccurrences(Object count);

  /// No description provided for @recurrenceCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get recurrenceCancel;

  /// No description provided for @recurrenceSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get recurrenceSave;

  /// No description provided for @recurrenceSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Recurrence'**
  String get recurrenceSetTitle;

  /// No description provided for @recurrenceDailyDesc.
  ///
  /// In en, this message translates to:
  /// **'Repeats every day.'**
  String get recurrenceDailyDesc;

  /// No description provided for @recurrenceMonthlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Repeats every month on this date.'**
  String get recurrenceMonthlyDesc;

  /// No description provided for @recurrenceYearlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Repeats every year on this date.'**
  String get recurrenceYearlyDesc;

  /// No description provided for @recurrenceRepeatsOn.
  ///
  /// In en, this message translates to:
  /// **'Repeats On'**
  String get recurrenceRepeatsOn;

  /// No description provided for @recurrenceEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get recurrenceEnds;

  /// No description provided for @recurrenceNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get recurrenceNever;

  /// No description provided for @recurrenceOnDate.
  ///
  /// In en, this message translates to:
  /// **'On Date'**
  String get recurrenceOnDate;

  /// No description provided for @recurrenceAfterOccurrences.
  ///
  /// In en, this message translates to:
  /// **'After N occurrences'**
  String get recurrenceAfterOccurrences;

  /// No description provided for @completedTasksText.
  ///
  /// In en, this message translates to:
  /// **'Completed Tasks'**
  String get completedTasksText;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutMessage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
