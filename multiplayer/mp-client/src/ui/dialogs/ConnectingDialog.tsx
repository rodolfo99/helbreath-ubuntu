import { useState } from 'react';
import type { StartingAttributes } from '../../proto/generated/network';
import { attributes } from '../../constants/CharacterAttributes';
import { HeadlessDraggableDialog } from './HeadlessDraggableDialog';

interface ConnectingDialogProps {
    points?: number;
    onCreate: (allocation: StartingAttributes) => void;
    position: { x: number; y: number };
    zIndex?: number;
    onBringToFront?: () => void;
}

export function ConnectingDialog({
    position,
    points,
    onCreate,
    zIndex,
    onBringToFront,
}: ConnectingDialogProps) {
    const [draft, setDraft] = useState<StartingAttributes>({
        strength: 0, vitality: 0, dexterity: 0, intelligence: 0, magicPower: 0,
    });
    const [submitted, setSubmitted] = useState(false);
    const remaining = (points ?? 0) - Object.values(draft).reduce((sum, n) => sum + n, 0);
    return (
        <HeadlessDraggableDialog
            position={position}
            id="connecting-dialog"
            zIndex={zIndex}
            onBringToFront={onBringToFront}
            onContextMenu={(e) => e.preventDefault()}
            disableDrag
        >
            <div style={{
                color: 'var(--rpg-parchment)',
                fontFamily: 'Georgia, serif',
                fontSize: '16px',
                lineHeight: '1.6',
                textAlign: 'center',
                padding: '16px',
            }}>
                {points === undefined || submitted ? <p style={{ margin: 0 }}>Conectando al servidor…</p> :
                    <form style={{ width: 'min(330px, 75vw)', textAlign: 'left' }} onSubmit={(event) => {
                        event.preventDefault();
                        if (remaining !== 0 || submitted) return;
                        setSubmitted(true);
                        onCreate(draft);
                    }}>
                        <h2 style={{ margin: '0 0 4px', color: 'var(--rpg-gold)' }}>Crear personaje</h2>
                        <p style={{ margin: '0 0 14px' }}>Reparte {points} puntos. Puedes cambiar el reparto antes de entrar.</p>
                        {attributes.map(([key, , label, effect]) =>
                            <label key={key} style={{ display: 'grid', gridTemplateColumns: '1fr 58px',
                                alignItems: 'center', gap: 8, margin: '8px 0' }}>
                                <span>{label}<small style={{ display: 'block', fontSize: 12 }}>{effect}</small></span>
                                <input aria-label={label} type="number" step="1" min={0} max={draft[key] + remaining}
                                    value={draft[key]} onFocus={event => event.target.select()}
                                    onChange={event => {
                                        const value = event.currentTarget.valueAsNumber;
                                        const next = Number.isFinite(value) ? Math.trunc(value) : 0;
                                        setDraft({ ...draft, [key]: Math.max(0, Math.min(draft[key] + remaining, next)) });
                                    }} />
                            </label>)}
                        <p aria-live="polite">Puntos por repartir: <strong>{remaining}</strong> de {points}</p>
                        <button type="submit" disabled={remaining !== 0}>Crear personaje y entrar</button>
                    </form>}
            </div>
        </HeadlessDraggableDialog>
    );
}
