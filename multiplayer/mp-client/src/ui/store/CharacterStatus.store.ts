import { Store } from '@tanstack/react-store';
import type { CharacterStats } from '../../proto/generated/network';

interface CharacterStatus {
    hp: number;
    maxHp: number;
    stats?: CharacterStats;
}

export const characterStatus = new Store<CharacterStatus>({ hp: 0, maxHp: 0 });
export function setCharacterHealth(hp: number, maxHp: number) {
    characterStatus.setState((state) => ({ ...state, hp, maxHp }));
}
export function setCharacterStats(stats?: CharacterStats) {
    characterStatus.setState((state) => ({ ...state, stats }));
}
