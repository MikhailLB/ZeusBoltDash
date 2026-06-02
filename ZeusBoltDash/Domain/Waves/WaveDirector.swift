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
        let radius = arenaRadius * Double.random(in: 0.88...0.96)
        let baseSpeed = 55.0 + Double(wave) * 4.0

        if isTitanWave {
            return Threat(kind: .titan, bearing: bearing, radius: radius, speed: baseSpeed * 0.75)
        }

        let roll = Double.random(in: 0...1)
        let kind: ThreatKind
        if roll < 0.08 { kind = .blessing }
        else if roll < 0.16 { kind = .essenceMote }
        else if roll < 0.52 { kind = .boulder }
        else if roll < 0.80 { kind = .darkBolt }
        else { kind = .shade }

        let speed = kind == .darkBolt || kind == .shade ? baseSpeed * 1.3 : baseSpeed
        return Threat(kind: kind, bearing: bearing, radius: radius, speed: speed)
    }
}
