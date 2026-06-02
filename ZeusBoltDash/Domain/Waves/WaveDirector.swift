import Foundation

final class WaveDirector {
    private(set) var wave = 1
    var isTitanWave: Bool { wave % 5 == 0 }

    private var quota = 0
    private var spawned = 0
    private var sinceSpawn = 0.0
    private var interWaveDelay = 1.2
    init() {}

    private var waveQuota: Int { isTitanWave ? 2 + wave / 4 : 6 + Int(Double(wave) * 1.4) }
    private var spawnInterval: Double { max(0.32, (isTitanWave ? 1.8 : 1.5) - Double(wave) * 0.072) }

    func reset() {
        wave = 1
        spawned = 0
        quota = 0
        sinceSpawn = 0
        interWaveDelay = 1.2
    }

    func update(dt: Double, arenaRadius: Double, liveThreats: Int, spawn: (Threat) -> Void) {
        if quota == 0 { quota = waveQuota }

        if interWaveDelay > 0 {
            interWaveDelay -= dt
            return
        }

        if spawned >= quota && liveThreats == 0 {
            wave += 1
            spawned = 0
            quota = waveQuota
            interWaveDelay = isTitanWave ? 1.6 : 1.0
            return
        }

        if spawned >= quota { return }

        sinceSpawn += dt
        if sinceSpawn >= spawnInterval {
            sinceSpawn = 0
            spawn(makeThreat(arenaRadius: arenaRadius))
            spawned += 1

            if !isTitanWave && wave >= 6 && spawned < quota &&
                Double.random(in: 0...1) < 0.18 + Double(wave) * 0.012 {
                spawn(makeThreat(arenaRadius: arenaRadius))
                spawned += 1
            }
        }
    }

    private func makeThreat(arenaRadius: Double) -> Threat {
        let bearing = Double.random(in: 0 ..< .pi * 2)
        let w = Double(wave)

        // Speeds mirror the Flutter `WaveDirector` so threats glide in from the
        // far spawn ring at a readable pace that escalates with the wave.
        let kind = rollKind()
        let speed: Double
        switch kind {
        case .boulder:     speed = 120 + w * 9
        case .darkBolt:    speed = 190 + w * 13
        case .shade:       speed = 100 + w * 8
        case .titan:       speed = 56 + w * 2.2
        case .blessing:    speed = 92 * min(1.6, 1 + w * 0.05)
        case .essenceMote: speed = 128 * min(1.7, 1 + w * 0.05)
        }
        return Threat(kind: kind, bearing: bearing, radius: arenaRadius, speed: speed)
    }

    private func rollKind() -> ThreatKind {
        if isTitanWave {
            let r = Double.random(in: 0...1)
            if r < 0.6 { return .titan }
            if r < 0.78 { return .darkBolt }
            if r < 0.92 { return .shade }
            return .blessing
        }

        let w = Double(wave)
        let r = Double.random(in: 0...1)
        let blessingCut = max(0.06, 0.16 - w * 0.004)
        let moteCut = blessingCut + max(0.05, 0.12 - w * 0.003)
        if r < blessingCut { return .blessing }
        if r < moteCut { return .essenceMote }

        let hostile = (r - moteCut) / (1 - moteCut)
        let boulderShare = max(0.28, 0.5 - w * 0.018)
        let boltShare = boulderShare + min(0.42, 0.3 + w * 0.01)
        if hostile < boulderShare { return .boulder }
        if hostile < boltShare { return .darkBolt }
        return .shade
    }
}
