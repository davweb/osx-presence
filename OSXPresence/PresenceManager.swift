import Foundation
import CocoaMQTT

struct Person: Identifiable, Decodable {
    let name: String
    let connected: Bool
    let lastSeen: Double?

    var id: String { name }

    enum CodingKeys: String, CodingKey {
        case name, connected
        case lastSeen = "last_seen"
    }

    var statusText: String {
        if connected { return "At Home" }
        guard let epoch = lastSeen else { return "Last Seen: Unknown" }
        return "Last Seen: \(Self.format(date: Date(timeIntervalSince1970: epoch)))"
    }

    private static func format(date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: date),
            to: calendar.startOfDay(for: now)
        ).day ?? 0

        if days > 365 { return "Long Ago" }

        if calendar.isDateInToday(date) {
            let f = DateFormatter()
            f.dateFormat = "HH:mm"
            return f.string(from: date)
        }

        if calendar.isDateInYesterday(date) { return "Yesterday" }

        if days < 7 {
            let f = DateFormatter()
            f.dateFormat = "EEEE"
            return f.string(from: date)
        }

        let f = DateFormatter()
        f.dateFormat = "d MMM"
        return f.string(from: date)
    }
}

class PresenceManager: NSObject, ObservableObject, CocoaMQTTDelegate {
    @Published var people: [Person] = []
    @Published var isConnected = false

    private var mqtt: CocoaMQTT?

    override init() {
        super.init()
        setupMQTT()
    }

    private func setupMQTT() {
        let clientId = "osx-presence-\(Int.random(in: 10000...99999))"
        let client = CocoaMQTT(clientID: clientId, host: "mosquitto.home.arpa", port: 1883)
        client.cleanSession = true
        client.keepAlive = 60
        client.autoReconnect = true
        client.autoReconnectTimeInterval = 5
        client.delegate = self
        mqtt = client
        client.connect()
    }

    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        guard ack == .accept else { return }
        DispatchQueue.main.async { self.isConnected = true }
        mqtt.subscribe("dashboard/presence", qos: .qos0)
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        let data = Data(message.payload)
        guard let people = try? JSONDecoder().decode([Person].self, from: data) else { return }
        DispatchQueue.main.async { self.people = people }
    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        DispatchQueue.main.async {
            self.isConnected = false
            self.people = []
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {}
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {}
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {}
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {}
    func mqttDidPing(_ mqtt: CocoaMQTT) {}
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {}
}
