import ClinerCore
import Foundation
import SwiftUI

struct Copy {
    var language: LanguageChoice

    var usesArabic: Bool {
        switch language {
        case .arabic:
            return true
        case .english:
            return false
        case .system:
            return Locale.preferredLanguages.first?.hasPrefix("ar") == true
        }
    }

    var locale: Locale {
        switch language {
        case .system:
            return .current
        case .arabic:
            return Locale(identifier: "ar")
        case .english:
            return Locale(identifier: "en")
        }
    }

    var appName: String { "Banish" }
    var tagline: String { text("Uninstall apps and the files they leave behind", "يزيل التطبيق وما يتركه خلفه") }
    var searchPrompt: String { text("Search by name or identifier", "ابحث بالاسم أو المعرّف") }
    var hideSystemApps: String { text("Hide system apps", "إخفاء تطبيقات النظام") }
    var scanning: String { text("Scanning applications…", "نفحص التطبيقات…") }
    var scanningRelated: String { text("Looking for related files…", "نبحث عن الملفات المرتبطة…") }
    var calculating: String { text("Calculating…", "نحسب الحجم…") }
    var chooseTitle: String { text("Choose an application", "اختر تطبيقاً") }
    var chooseDetail: String {
        text(
            "The app and the files it usually leaves behind will appear here.",
            "ستظهر هنا حزمة التطبيق والملفات التي يبقى أثرها عادةً بعد الحذف."
        )
    }
    var relatedTitle: String { text("Related files", "ملفات مرتبطة") }
    var reviewTitle: String { text("Name matches", "تطابق بالاسم") }
    var reviewDetail: String {
        text(
            "These match the name only, so they stay unselected. Check the path before including them.",
            "هذه الملفات تطابق الاسم فقط، لذلك لم نحددها. راجع المسار قبل إضافتها."
        )
    }
    var noLeftovers: String {
        text(
            "No related files found. You can still move the app itself.",
            "لم نعثر على ملفات مرتبطة. يمكنك نقل التطبيق وحده."
        )
    }
    var moveToTrash: String { text("Move to Trash", "نقل إلى سلة المهملات") }
    var cancel: String { text("Cancel", "إلغاء") }
    var appBundle: String { text("Application bundle", "حزمة التطبيق") }
    var protectedTitle: String { text("System app", "تطبيق نظام") }
    var protectedDetail: String {
        text(
            "System apps stay where they are. Banish will not move them or their files.",
            "تطبيقات النظام تبقى في مكانها. Banish لا ينقلها ولا يحذف ملفاتها."
        )
    }
    var running: String { text("Running", "يعمل الآن") }
    var showInFinder: String { text("Show in Finder", "إظهار في Finder") }
    var refresh: String { text("Refresh", "تحديث") }
    var sort: String { text("Sort", "الترتيب") }
    var sortByName: String { text("Name", "الاسم") }
    var sortBySize: String { text("Size", "الحجم") }
    var viewOptions: String { text("View", "العرض") }
    var appSize: String { text("App size", "حجم التطبيق") }
    var relatedSize: String { text("Related files", "الملفات المرتبطة") }
    var selectedSpace: String { text("Selected", "المحدد للنقل") }
    var confirmTitle: String { text("Move to the Trash?", "نقل إلى سلة المهملات؟") }
    var confirmSafe: String {
        text(
            "Nothing is deleted permanently. You can put the items back from the Trash.",
            "لن يُحذف شيء نهائياً. يمكنك استرجاع العناصر من سلة المهملات."
        )
    }
    var confirmQuit: String {
        text(
            "This app is running. Banish will try to quit it before moving its files.",
            "التطبيق يعمل الآن، وسنحاول إغلاقه قبل نقل ملفاته."
        )
    }
    var confirmApple: String {
        text(
            "This is an Apple app. Make sure you want to remove it.",
            "هذا تطبيق من آبل. تأكد أنك تريد إزالته."
        )
    }
    var quitFailed: String {
        text(
            "Banish could not quit the app. Quit it yourself, then try again.",
            "تعذّر إغلاق التطبيق. أوقفه ثم أعد المحاولة."
        )
    }
    var nothingSelected: String { text("Select at least one item.", "حدّد عنصراً واحداً على الأقل.") }
    var permissionTitle: String { text("Some folders are not readable", "بعض المجلدات غير مقروءة") }
    var permissionDetail: String {
        text(
            "Full Disk Access lets Banish see more leftovers, such as containers and caches.",
            "منح «الوصول الكامل إلى القرص» يتيح رؤية ملفات أكثر، مثل الحاويات والكاش."
        )
    }
    var openSettings: String { text("Open Privacy Settings", "فتح إعدادات الخصوصية") }
    var notNow: String { text("Not Now", "ليس الآن") }
    var selectAll: String { text("Select all", "تحديد الكل") }
    var selectNone: String { text("Deselect", "إلغاء التحديد") }
    var includeNameMatches: String { text("Include name matches", "تضمين تطابق الاسم") }
    var languageTitle: String { text("Language", "اللغة") }
    var systemLanguage: String { text("System", "حسب النظام") }
    var arabic: String { "العربية" }
    var english: String { "English" }
    var about: String { text("About Banish", "حول Banish") }
    var settingsSafety: String {
        text(
            "Banish moves only what you select to the Trash. It does not delete Mail, Photos, Keychains, or Apple files that do not belong to the app.",
            "Banish ينقل ما تحدده فقط إلى سلة المهملات. لا يحذف البريد، ولا الصور، ولا سلسلة المفاتيح، ولا ملفات آبل التي لا تتبع التطبيق."
        )
    }
    var trashFootnote: String {
        text(
            "Items go to the Trash. You can put them back.",
            "العناصر تذهب إلى سلة المهملات، ويمكنك استرجاعها منها."
        )
    }
    var noResults: String { text("No results", "لا توجد نتائج") }
    var noResultsDetail: String {
        text(
            "Try another name, or show system apps from the View menu.",
            "جرّب اسماً آخر، أو أظهر تطبيقات النظام من قائمة العرض."
        )
    }
    var applicationsUnreadable: String {
        text(
            "Banish could not read the Applications folder.",
            "تعذّر قراءة مجلد التطبيقات."
        )
    }
    var appleBadge: String { text("Apple", "آبل") }
    var systemBadge: String { text("System", "نظام") }
    var confirmFailed: String { text("The move did not finish.", "لم يكتمل النقل.") }
    var working: String { text("Moving…", "جارٍ النقل…") }
    var passwordHint: String {
        text(
            "macOS may ask for your password to move apps out of the Applications folder.",
            "قد يطلب macOS كلمة السر لنقل التطبيقات من مجلد التطبيقات."
        )
    }
    var adminPrompt: String {
        text(
            "Banish needs your password to move this app to the Trash.",
            "يحتاج Banish إلى كلمة السر لنقل هذا التطبيق إلى سلة المهملات."
        )
    }
    var passwordCanceled: String {
        text(
            "The password dialog was canceled. macOS needs it to move apps out of the Applications folder.",
            "أُلغي طلب كلمة السر. يحتاجها macOS لنقل التطبيقات من مجلد التطبيقات."
        )
    }

    func appsFooter(_ value: Int) -> String {
        if !usesArabic {
            return value == 1 ? "1 application" : "\(count(value)) applications"
        }
        switch value {
        case 0: return "لا تطبيقات"
        case 1: return "تطبيق واحد"
        case 2: return "تطبيقان"
        case 3...10: return "\(count(value)) تطبيقات"
        default: return "\(count(value)) تطبيقاً"
        }
    }

    func itemCount(_ value: Int) -> String {
        if !usesArabic {
            return value == 1 ? "1 item" : "\(count(value)) items"
        }
        switch value {
        case 0: return "لا عناصر"
        case 1: return "عنصر واحد"
        case 2: return "عنصران"
        case 3...10: return "\(count(value)) عناصر"
        default: return "\(count(value)) عنصراً"
        }
    }

    func confirmSummary(count: Int, size: String) -> String {
        if usesArabic {
            return "سننقل \(itemCount(count)) (\(size)) إلى سلة المهملات."
        }
        return "This will move \(itemCount(count)) (\(size)) to the Trash."
    }

    func andMore(_ value: Int) -> String {
        if usesArabic {
            return "و\(count(value)) مسارات أخرى"
        }
        return "and \(count(value)) more paths"
    }

    func selectionSummary(count: Int, bytes: String?) -> String {
        let items = itemCount(count)
        let size = bytes ?? calculating
        return "\(items) · \(size)"
    }

    func bytes(_ value: Int64?) -> String {
        guard let value else { return calculating }
        return ByteText.format(value, locale: locale)
    }

    func categoryTitle(_ category: LeftoverCategory) -> String {
        switch category {
        case .applicationSupport: text("Application Support", "دعم التطبيق")
        case .caches: text("Caches", "الكاش")
        case .preferences: text("Preferences", "التفضيلات")
        case .logs: text("Logs", "السجلات")
        case .savedState: text("Saved State", "الحالة المحفوظة")
        case .containers: text("Containers", "الحاويات")
        case .groupContainers: text("Group Containers", "الحاويات المشتركة")
        case .webData: text("Web Data", "بيانات الويب")
        case .launchAgents: text("Launch Agents", "وكلاء التشغيل")
        case .launchDaemons: text("Launch Daemons", "خدمات التشغيل")
        case .scripts: text("Scripts", "السكربتات")
        case .developer: text("Developer", "أدوات المطوّر")
        }
    }

    func noticeText(_ notice: LibraryNotice) -> String {
        switch notice {
        case .success(let count):
            return usesArabic
                ? "نُقل \(itemCount(count)) إلى سلة المهملات."
                : "Moved \(itemCount(count)) to the Trash."
        case .quitFailed:
            return quitFailed
        case .partial(let ok, let failed, let detail):
            if usesArabic {
                return "نُقل \(itemCount(ok)) وتعذّر نقل \(itemCount(failed)). \(detail)"
            }
            return "Moved \(itemCount(ok)). Could not move \(itemCount(failed)). \(detail)"
        case .rejected(let reason):
            return rejection(reason)
        case .failed(let message):
            if message.isEmpty { return confirmFailed }
            return usesArabic ? "تعذّر النقل. \(message)" : "Could not move the items. \(message)"
        case .nothingSelected:
            return nothingSelected
        case .authorizationCanceled(let moved):
            if moved == 0 { return passwordCanceled }
            if usesArabic {
                return "نُقل \(itemCount(moved)). \(passwordCanceled)"
            }
            return "Moved \(itemCount(moved)). \(passwordCanceled)"
        }
    }

    func rejection(_ reason: RejectionReason) -> String {
        switch reason {
        case .notPermitted:
            text("This path is not one of the files found for the app.", "هذا المسار ليس من ملفات التطبيق التي عثرنا عليها.")
        case .outsideAllowedRoots:
            text("This path is outside Applications and Library.", "هذا المسار خارج مجلدي التطبيقات والمكتبة.")
        case .sensitiveLocation:
            text("This location is personal data, and Banish will not touch it.", "هذا موقع شخصي، ولن نلمسه.")
        case .unrelatedAppleFile:
            text("This Apple file does not belong to the selected app.", "هذا ملف تابع لآبل وليس للتطبيق المحدد.")
        case .systemLocation:
            text("System locations cannot be moved.", "لا يمكن نقل ملفات النظام.")
        case .escapesRoot:
            text("This item is a link that points somewhere else.", "هذا العنصر رابط يشير إلى مكان آخر.")
        case .notAnApplicationBundle:
            text("This is not a valid application.", "هذا ليس تطبيقاً صالحاً.")
        case .missingTarget:
            text("The file is already gone.", "الملف لم يعد موجوداً.")
        case .pathTooShallow:
            text("This folder is too broad to move.", "هذا المجلد عام جدًا ولن ننقله.")
        case .currentApplication:
            text("Banish cannot move itself.", "لا يمكن لـ Banish نقل نفسه.")
        case .unexpectedApplicationLocation:
            text("This application is not in a normal Applications folder.", "هذا التطبيق ليس في مجلد التطبيقات المعتاد.")
        }
    }

    private func count(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }

    private func text(_ english: String, _ arabic: String) -> String {
        usesArabic ? arabic : english
    }
}

private struct CopyKey: EnvironmentKey {
    static let defaultValue = Copy(language: .system)
}

extension EnvironmentValues {
    var copy: Copy {
        get { self[CopyKey.self] }
        set { self[CopyKey.self] = newValue }
    }
}

extension View {
    @ViewBuilder
    func clinerChrome(_ preferences: Preferences) -> some View {
        let copy = Copy(language: preferences.language)
        switch preferences.language {
        case .system:
            self.environment(preferences).environment(\.copy, copy)
        case .arabic:
            self
                .environment(preferences)
                .environment(\.copy, copy)
                .environment(\.layoutDirection, .rightToLeft)
                .environment(\.locale, Locale(identifier: "ar"))
        case .english:
            self
                .environment(preferences)
                .environment(\.copy, copy)
                .environment(\.layoutDirection, .leftToRight)
                .environment(\.locale, Locale(identifier: "en"))
        }
    }
}
