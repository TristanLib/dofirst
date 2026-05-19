import SwiftUI

struct TotalActivityView: View {
    let totalActivity: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("系统屏幕时间")
                .font(.headline)
            Text(totalActivity)
                .font(.title2.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}

#Preview {
    TotalActivityView(totalActivity: "1h 23m")
}

