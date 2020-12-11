import SwiftUI
import WidgetKit

@main
struct SwiftWidgetsBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        RandomWidget()
        ReminderWidget()
    }
}
