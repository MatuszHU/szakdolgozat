import Foundation
import SharedKit

@M11
enum GuestPlace: String, CaseIterable {
    case home
    case ticketShop
    case myTickets
    case map
    case raffle
}

extension GuideTipCenter {
    @M11
    static func guest(store: TipStoring) -> GuideTipCenter {
        GuideTipCenter(tips: [
            GuestPlace.home.rawValue: GuideTip(
                id: GuestPlace.home.rawValue, title: "Üdv a Nightlife-ban!",
                message: "Itt vásárolhatsz jegyet, megtalálod a helyszín térképét és jelentkezhetsz a nyereményjátékokra.",
                symbol: "sparkles"),
            GuestPlace.ticketShop.rawValue: GuideTip(
                id: GuestPlace.ticketShop.rawValue, title: "Így vásárolsz jegyet",
                message: "Válassz eseményt és jegytípust, add meg a darabszámot, majd fizess. A jegyeid a Jegyeim között jelennek meg.",
                symbol: "cart.fill"),
            GuestPlace.myTickets.rawValue: GuideTip(
                id: GuestPlace.myTickets.rawValue, title: "A jegyeid",
                message: "A bejáratnál mutasd fel a jegyed QR-kódját. Minden jegy egyszer használható fel.",
                symbol: "qrcode"),
            GuestPlace.map.rawValue: GuideTip(
                id: GuestPlace.map.rawValue, title: "Így találsz meg mindent",
                message: "Válts a szintek között, és megtalálod a bárt, a mosdókat, a színpadot és a kijáratokat.",
                symbol: "map.fill"),
            GuestPlace.raffle.rawValue: GuideTip(
                id: GuestPlace.raffle.rawValue, title: "Nyereményjátékok",
                message: "Az esemény végéig egyszer jelentkezhetsz egy nyereményjátékra. Sok szerencsét!",
                symbol: "gift.fill"),
        ], store: store)
    }

    @M11
    func visit(_ place: GuestPlace) {
        visit(place.rawValue)
    }
}
