import Foundation

class IncendiumShortSword: IUnitComponent {
    func modifyOutgoingAttack(game: Game, selfUnit: Int) -> AttackModifier {
        return AttackModifier(initialDamage100: 700, damageMultiply100: 100, damageAdd100: 200)
    }
}

class GoblinClaws: IUnitComponent {
    func modifyOutgoingAttack(game: Game, selfUnit: Int) -> AttackModifier {
        return AttackModifier(initialDamage100: 150, damageMultiply100: 100, damageAdd100: 0)
    }
}
