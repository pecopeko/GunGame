import 'entities.dart';

class UnitFactory {
  const UnitFactory();

  /// Create a new unit with the given role and team
  UnitState createUnit({
    required String id,
    required TeamId team,
    required Role role,
    String posTileId = '',
  }) {
    final card = _getCardForRole(role);
    return UnitState(
      unitId: id,
      team: team,
      card: card,
      hp: card.maxHp,
      posTileId: posTileId,
      alive: true,
      activatedThisRound: false,
      statuses: const [],
      cooldowns: const {},
      charges: {
        SkillSlot.skill1: card.skill1.maxCharges ?? 0,
        SkillSlot.skill2: card.skill2.maxCharges ?? 0,
      },
    );
  }

  UnitCard _getCardForRole(Role role) {
    switch (role) {
      case Role.entry:
        return const UnitCard(
          cardId: 'entry',
          role: Role.entry,
          displayName: 'Duelist',
          maxHp: 1,
          moveRange: 3,
          attackRange: 999,
          skill1: SkillDef(
            name: 'Stun',
            description: 'Stun target tile (3 tiles away)',
            range: 3,
            maxCharges: 2,
          ),
          skill2: SkillDef(
            name: 'Dash',
            description: 'Dash with smoke (5 tiles away)',
            range: 5,
            maxCharges: 1,
          ),
        );
      case Role.recon:
        return const UnitCard(
          cardId: 'recon',
          role: Role.recon,
          displayName: 'Initiator',
          maxHp: 1,
          moveRange: 2,
          attackRange: 999,
          skill1: SkillDef(
            name: 'Drone',
            description: 'Deploy adjacent (1 tile)',
            range: 1,
            maxCharges: 1,
          ),
          skill2: SkillDef(
            name: 'Flash',
            description: 'Blind 2 rounds, no vision, cannot shoot',
            range: 5,
            maxCharges: 2,
          ),
        );
      case Role.smoke:
        return const UnitCard(
          cardId: 'smoke',
          role: Role.smoke,
          displayName: 'Smoke',
          maxHp: 1,
          moveRange: 2,
          attackRange: 999,
          skill1: SkillDef(
            name: 'Smoke',
            description: 'Block vision (10 turns)',
            range: 10,
            maxCharges: 3,
          ),
          skill2: SkillDef(
            name: 'Empty', // Placeholder or null
            description: 'No second skill',
            maxCharges: 0,
          ),
        );
      case Role.sentinel:
        return const UnitCard(
          cardId: 'sentinel',
          role: Role.sentinel,
          displayName: 'Sentinel',
          maxHp: 1,
          moveRange: 2,
          attackRange: 999,
          skill1: SkillDef(
            name: 'Trap',
            description: 'End enemy turn on trigger',
            maxCharges: 1,
          ),
          skill2: SkillDef(
            name: 'Camera',
            description: 'Reveal on sight (2 tiles away)',
            maxCharges: 1,
            range: 2,
          ),
        );
    }
  }
}
