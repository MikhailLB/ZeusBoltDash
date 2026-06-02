import Foundation

final class WaveDirector {
    private(set) var wave = 1
    private(set) var isTitanWave = false

    private var quota = 0
    private var spawned = 0
    private var elapsed = 0.0
    private var interWaveDelay = 0.0
    private var spawnInterval = 0.0
    private var spawnClock = 0.0
    init() {}

    func update(dt: Double, arenaRadius: Double, liveThreats: Int, spawn: (Threat) -> Void) {
        if interWaveDelay > 0 {
            interWaveDelay -= dt
            if interWaveDelay <= 0 { startWave() }
            return
        }

        if spawned >= quota && liveThreats == 0 {
            interWaveDelay = 2.2
            wave += 1
            return
        }

        if spawned < quota {
            spawnClock -= dt
            if spawnClock <= 0 {
                spawnClock = spawnInterval
                spawn(makeThreat(arenaRadius: arenaRadius))
                spawned += 1

                if !isTitanWave && wave >= 6 && Double.random(in: 0...1) < 0.18 + Double(wave) * 0.012 {
                    spawn(makeThreat(arenaRadius: arenaRadius))
                    spawned += 1
                }
            }
        }
    }

    private func startWave() {
        isTitanWave = wave % 5 == 0
        quota = isTitanWave ? 2 + wave / 5 : 4 + wave * 2
        spawned = 0
        spawnInterval = max(0.5, 2.0 - Double(wave) * 0.08)
        spawnClock = 0.3
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
