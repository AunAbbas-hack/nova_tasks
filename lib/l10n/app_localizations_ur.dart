// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get settings => 'سیٹنگز';

  @override
  String get profileName => 'انڈریا';

  @override
  String get profileEmail => 'andria@email.com';

  @override
  String get appearance => 'ظاہری شکل';

  @override
  String get darkMode => 'ڈارک موڈ';

  @override
  String get systemDefault => 'سسٹم ڈیفالٹ';

  @override
  String get defaultHomeView => 'ڈیفالٹ ہوم ویو';

  @override
  String get today => 'آج';

  @override
  String get general => 'جنرل';

  @override
  String get defaultReminderTime => 'ڈیفالٹ ریمائنڈر ٹائم';

  @override
  String get time0900am => 'صبح 09:00';

  @override
  String get language => 'زبان';

  @override
  String get english => 'انگریزی';

  @override
  String get account => 'اکاؤنٹ';

  @override
  String get logout => 'لاگ آؤٹ';

  @override
  String get urdu => 'اردو';

  @override
  String get week => 'ہفتہ';

  @override
  String get tasksCompletedLabel => 'مکمل شدہ ٹاسکس';

  @override
  String get onTimeRateLabel => 'وقت پر مکمل کرنے کی شرح';

  @override
  String get currentStreakLabel => 'موجودہ سلسلہ';

  @override
  String get profile => 'پروفائل';

  @override
  String get fullName => 'پورا نام';

  @override
  String get email => 'ای میل';

  @override
  String get productivityInsights => 'پروڈکٹیویٹی ان سائٹس';

  @override
  String tasksCompleted(int count) {
    return '$count مکمل شدہ ٹاسکس';
  }

  @override
  String onTimeRate(double percent) {
    return '$percent% وقت پر مکمل کرنے کی شرح';
  }

  @override
  String currentStreak(int days) {
    return '$days دن کا سلسلہ';
  }

  @override
  String get notifications => 'نوٹیفیکیشنز';

  @override
  String get saveChanges => 'تبدیلیاں محفوظ کریں';

  @override
  String get clearAll => 'تمام صاف کریں';

  @override
  String get noNotificationsTitle => 'آپ مکمل طور پر اپ ٹو ڈیٹ ہیں!';

  @override
  String get noNotificationsSubtitle => 'اس وقت کوئی نوٹیفیکیشن نہیں';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsClearAll => 'Clear All';

  @override
  String get notificationsToday => 'Today';

  @override
  String get notificationsYesterday => 'گزشتہ دن';

  @override
  String get notificationDueSoonTitle => 'جلد مکمل ہونے والا ٹاسک';

  @override
  String get notificationOverdueTitle => 'وقت گزر جانے والا ٹاسک';

  @override
  String get notificationProductivityInsightTitle => 'پیداواری کارکردگی';

  @override
  String get notificationCollaborationTitle => 'تعاون کی تازہ کاری';

  @override
  String notificationDueSoonMessage(Object taskTitle, Object relativeTime) {
    return '$taskTitle: $relativeTime میں مکمل کرنا ہے';
  }

  @override
  String notificationOverdueMessage(Object taskTitle, Object relativeTime) {
    return '$taskTitle: $relativeTime پہلے';
  }

  @override
  String notificationProductivityInsightMessage(Object completedCount) {
    return 'آپ نے کل $completedCount ٹاسک مکمل کیے!';
  }

  @override
  String notificationCollaborationMessage(Object assignerName) {
    return '$assignerName نے آپ کو نیا ٹاسک دیا ہے';
  }

  @override
  String get notificationSnoozeButton => 'اسنوز';

  @override
  String get notificationMarkDoneButton => 'مکمل کریں';

  @override
  String get notificationActivityTitle => 'نئی ٹاسکس';

  @override
  String get notificationActivityMessage => 'آپ نے کل نئی ٹاسکس بنائیں۔';

  @override
  String get markAsDone => 'مکمل کے طور پر نشان زد کریں';

  @override
  String get snooze => 'مؤخر کریں';

  @override
  String get hi => 'ہیلو';

  @override
  String get showAll => 'سب دکھائیں';

  @override
  String get filterAll => 'تمام';

  @override
  String get filterPersonal => 'ذاتی';

  @override
  String get filterWork => 'کام';

  @override
  String tasksForDay(Object day, Object date) {
    return '$day، $date ';
  }

  @override
  String get noTasksForDay => 'آج کے لیے کوئی کام موجود نہیں';

  @override
  String get bottomNavHome => 'ہوم';

  @override
  String get bottomNavCalendar => 'کیلنڈر';

  @override
  String get bottomNavMe => 'پروفائل';

  @override
  String get dayMon => 'پیر';

  @override
  String get dayTue => 'منگل';

  @override
  String get dayWed => 'بدھ';

  @override
  String get dayThu => 'جمعرات';

  @override
  String get dayFri => 'جمعہ';

  @override
  String get daySat => 'ہفتہ';

  @override
  String get daySun => 'اتوار';

  @override
  String get filterTitleShow => 'دکھائیں';

  @override
  String get filterAllTasks => 'تمام (آج + زائد المیعاد + آنے والے)';

  @override
  String get filterOverdueTasks => 'زائد المیعاد کام';

  @override
  String get filterTodayTasks => 'آج کے کام';

  @override
  String get filterUpcomingTasks => 'آنے والے کام';

  @override
  String get filterCancelButton => 'منسوخ کریں';

  @override
  String get filterApplyButton => 'لاگو کریں';

  @override
  String get allTasks => 'All Tasks';

  @override
  String get noTasksForFilter => 'اس فلٹر کے لیے کوئی کام نہیں ملا۔';

  @override
  String get deleteTaskTitle => 'کام حذف کریں؟';

  @override
  String get deleteTaskMessage => 'کیا آپ واقعی اس کام کو حذف کرنا چاہتے ہیں؟';

  @override
  String get cancelAction => 'منسوخ کریں';

  @override
  String get deleteAction => 'حذف کریں';

  @override
  String get editTaskTitle => 'اپ ڈیٹ کریں';

  @override
  String get newTaskTitle => 'نیا کام';

  @override
  String get saveAction => 'محفوظ کریں';

  @override
  String get taskTitleLabel => 'کام کا عنوان';

  @override
  String get taskTitleHint => 'مثال کے طور پر، نیا ڈیش بورڈ ڈیزائن کریں';

  @override
  String get taskDescriptionLabel => 'تفصیل';

  @override
  String get taskDescriptionHint => 'کام کے بارے میں تفصیلات شامل کریں...';

  @override
  String get dueDateLabel => 'مقررہ تاریخ';

  @override
  String get timeLabel => 'وقت';

  @override
  String get priorityLabel => 'اہمیت';

  @override
  String get priorityLow => 'کم';

  @override
  String get priorityMedium => 'درمیانی';

  @override
  String get priorityHigh => 'ضروری';

  @override
  String get priorityUrgent => 'انتہائی ضروری';

  @override
  String get categoryLabel => 'زمرہ';

  @override
  String get categoryWork => 'کام';

  @override
  String get recurringTaskLabel => 'دوبارہ ہونے والا کام';

  @override
  String get recurringTaskHint => 'کام کو بار بار ہونے کے لیے سیٹ کریں';

  @override
  String get subtasksLabel => 'ذیلی کام';

  @override
  String get subtasksProgressLabel => 'پیش رفت';

  @override
  String subtasksCompletedStatus(Object completed, Object total) {
    return '$completed میں سے $total مکمل';
  }

  @override
  String get addSubtaskAction => 'ذیلی کام شامل کریں';

  @override
  String get enterSubTask => 'ذیلی کام درج کریں۔';

  @override
  String get createTaskAction => 'کام بنائیں';

  @override
  String get categoryPersonal => 'ذاتی';

  @override
  String get categoryCustom => 'حسبِ ضرورت';

  @override
  String get enterCustomCategory => 'حسبِ ضرورت زمرہ درج کریں';

  @override
  String get updating => 'اپ ڈیٹ کیا جا رہا ہے...';

  @override
  String get creating => 'بنا یا جا رہا ہے...';

  @override
  String get updateTaskAction => 'ٹاسک اپ ڈیٹ کریں';

  @override
  String get loginRequiredToAddTask =>
      'ٹاسک شامل کرنے کے لیے لاگ ان ہونا ضروری ہے';

  @override
  String get taskCreated => 'ٹاسک تخلیق ہوگیا';

  @override
  String get taskUpdated => 'ٹاسک اپڈیٹ ہوگیا';

  @override
  String get noSubtasksAdded => 'کوئی ذیلی ٹاسک شامل نہیں کیا گیا۔';

  @override
  String get noDescriptionAdded => 'کوئی وضاحت شامل نہیں کی گئی۔';

  @override
  String get taskDetails => 'ٹاسک کی تفصیلات';

  @override
  String get january => 'جنوری';

  @override
  String get february => 'فروری';

  @override
  String get march => 'مارچ';

  @override
  String get april => 'اپریل';

  @override
  String get may => 'مئی';

  @override
  String get june => 'جون';

  @override
  String get july => 'جولائی';

  @override
  String get august => 'اگست';

  @override
  String get september => 'ستمبر';

  @override
  String get october => 'اکتوبر';

  @override
  String get november => 'نومبر';

  @override
  String get december => 'دسمبر';

  @override
  String get tasksFrom => 'ٹاسک سے';

  @override
  String get tasksFor => 'ٹاسک';

  @override
  String get tasksInThisRange => 'اس حد میں ٹاسک';

  @override
  String get tasksForThisDay => 'اس دن کے لیے ٹاسک';

  @override
  String get noTasks => 'کوئی ٹاسک نہیں...';

  @override
  String get month => 'مہینہ';

  @override
  String get addButton => 'شامل کریں';

  @override
  String get markAsCompleted => 'مکمل کے طور پر نشان زد کریں';

  @override
  String get markAsIncomplete => 'نامکمل کے طور پر نشان زد کریں';

  @override
  String get exitAppTitle => 'ایپ بند کریں';

  @override
  String get exitAppMessage => 'کیا آپ واقعی ایپ بند کرنا چاہتے ہیں؟';

  @override
  String get no => 'نہیں';

  @override
  String get yes => 'ہاں';

  @override
  String get recurrenceRepeats => 'دہرایا جائے گا';

  @override
  String get recurrenceDaily => 'روزانہ';

  @override
  String get recurrenceWeekly => 'ہفتہ وار';

  @override
  String get recurrenceMonthly => 'ماہانہ';

  @override
  String get recurrenceYearly => 'سالانہ';

  @override
  String get recurrenceEvery => 'ہر';

  @override
  String get weekdayMon => 'پیر';

  @override
  String get weekdayTue => 'منگل';

  @override
  String get weekdayWed => 'بدھ';

  @override
  String get weekdayThu => 'جمعرات';

  @override
  String get weekdayFri => 'جمعہ';

  @override
  String get weekdaySat => 'ہفتہ';

  @override
  String get weekdaySun => 'اتوار';

  @override
  String get recurrenceForever => 'ہمیشہ';

  @override
  String get recurrenceUntil => 'تک';

  @override
  String recurrenceForOccurrences(Object count) {
    return '$count مرتبہ کے لیے';
  }

  @override
  String get recurrenceCancel => 'منسوخ';

  @override
  String get recurrenceSave => 'محفوظ کریں';

  @override
  String get recurrenceSetTitle => 'دہراؤ سیٹ کریں';

  @override
  String get recurrenceDailyDesc => 'ہر دن دہرایا جائے گا۔';

  @override
  String get recurrenceMonthlyDesc => 'ہر مہینے اسی تاریخ کو دہرایا جائے گا۔';

  @override
  String get recurrenceYearlyDesc => 'ہر سال اسی تاریخ کو دہرایا جائے گا۔';

  @override
  String get recurrenceRepeatsOn => 'دہراؤ کے دن';

  @override
  String get recurrenceEnds => 'اختتام';

  @override
  String get recurrenceNever => 'کبھی نہیں';

  @override
  String get recurrenceOnDate => 'تاریخ پر';

  @override
  String get recurrenceAfterOccurrences => 'مقررہ دفعہ کے بعد';

  @override
  String get completedTasksText => 'مکمل شدہ کام';

  @override
  String get logoutTitle => 'لاگ آؤٹ';

  @override
  String get logoutMessage => 'کیا آپ واقعی لاگ آؤٹ کرنا چاہتے ہیں؟';
}
