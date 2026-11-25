import { useStore } from '@tanstack/react-store';
import { characterStatus } from '../store/CharacterStatus.store';

function Meter({ label, value, max }: { label: string; value: number; max: number }) {
    return <div className="character-meter" data-meter={label}>
        <label>{label} <progress aria-label={label} max={max} value={value} /></label>
        <span>{value}/{max}</span>
    </div>;
}

export function CharacterMeters() {
    const { hp, maxHp, stats } = useStore(characterStatus, (state) => state);
    if (!stats || maxHp < 1 || stats.maxMana < 1) return null;
    return <div className="character-meters">
        <Meter label="HP" value={hp} max={maxHp} />
        <Meter label="Maná" value={stats.mana} max={stats.maxMana} />
    </div>;
}
