import Foundation
import SharedKit

@K15
enum GuideTopic: Hashable {
    case home(HomeItem)
    case settings
}

@K15
struct GuideSection: Identifiable {
    let topic: GuideTopic
    let title: LocalizedStringResource
    let symbol: String
    let text: LocalizedStringResource

    var id: GuideTopic { topic }
}

@K15
struct GuideViewModel {
    let menu: HomeMenuViewModel

    var sections: [GuideSection] {
        menu.items.map { GuideSection(topic: .home($0), title: $0.title, symbol: $0.symbol, text: $0.guideText) }
            + [GuideSection(topic: .settings, title: "Beállítások", symbol: "gearshape",
                            text: "A profilkép, a nyelv, az útmutató, a névjegy és a kijelentkezés egy helyen.")]
    }
}

extension HomeItem {
    @K15
    var title: LocalizedStringResource {
        switch self {
        case .schedule: return "Beosztás"
        case .notifications: return "Értesítések"
        case .codeReader: return "Kódolvasó"
        case .map: return "Térkép"
        case .supplyRequest: return "Készletkérés"
        case .summary: return "Összesítés"
        }
    }

    @K15
    var symbol: String {
        switch self {
        case .schedule: return "calendar"
        case .notifications: return "bell"
        case .codeReader: return "qrcode.viewfinder"
        case .map: return "map"
        case .supplyRequest: return "shippingbox"
        case .summary: return "chart.bar"
        }
    }

    @K15
    var guideText: LocalizedStringResource {
        switch self {
        case .schedule:
            return "A saját műszakjaid időponttal, szinttel, zónával és a neked kiosztott feladatokkal. A folyamatban lévő műszak külön látszik, a korábbiak a lista alján."
        case .notifications:
            return "Az elbírált készletkérések, a neked szóló pánikjelzések és az új beosztások egy listában. Koppintásra olvasottá válnak."
        case .codeReader:
            return "Jegyek beléptetése és zóna-bejelentkezés: irányítsd a kamerát a QR-kódra. Műszak alatt a zóna kódjával jelzed, hol vagy."
        case .map:
            return "A helyszín tervrajza szintenként, a munkaterületeddel és azzal, hogy a kollégák melyik zónában jelentkeztek be utoljára."
        case .supplyRequest:
            return "Jelezd, ha valami elfogyott vagy hamarosan elfogy. A kérés állapotát a lista alján követheted; tételenként egy nyitott kérésed lehet."
        case .summary:
            return "A ledolgozott óráid az aktuális és az előző elszámolási időszakban, valamint a korábbi feladataid."
        }
    }
}
