import { useEffect, useState, type CSSProperties } from 'react';
import { useStore } from '@tanstack/react-store';
import { DraggableDialog } from './DraggableDialog';
import { RpgButton } from '../components/RpgButton';
import { EventBus } from '../../game/EventBus';
import { IN_UI_CONNECT_TO_SERVER, TOAST_REQUESTED } from '../../constants/EventNames';
import { connectDialogStore, setConnectDialogOpen, setLastConnectAttempt } from '../store/ConnectDialog.store';

const adminLogin = new URLSearchParams(window.location.search).has('admin');
const defaultHost = window.location.hostname || '127.0.0.1';
const defaultPort = import.meta.env.DEV ? 1337 : Number(window.location.port || (window.location.protocol === 'https:' ? 443 : 80));

const inputStyle: CSSProperties = {
    width: '100%',
    boxSizing: 'border-box',
    padding: '6px 8px',
    marginTop: '4px',
    fontFamily: 'Georgia, serif',
    fontSize: '14px',
    color: 'var(--rpg-parchment)',
    backgroundColor: 'rgba(0,0,0,0.35)',
    border: '1px solid #704214',
    borderRadius: '2px',
};

interface ConnectDialogProps {
    position: { x: number; y: number };
    zIndex?: number;
    onBringToFront?: () => void;
}

export function ConnectDialog({
    position,
    zIndex,
    onBringToFront,
}: ConnectDialogProps) {
    const { isOpen, defaultCharacterName, lastAttempt } = useStore(connectDialogStore, (s) => s);
    const [characterName, setCharacterName] = useState('');
    const [adminKey, setAdminKey] = useState('');
    const [host, setHost] = useState(defaultHost);
    const [portText, setPortText] = useState(String(defaultPort));

    useEffect(() => {
        if (!isOpen) {
            return;
        }
        const init = lastAttempt ?? {
            characterName: defaultCharacterName,
            host: defaultHost,
            port: defaultPort,
        };
        setCharacterName(init.characterName);
        setHost(init.host);
        setPortText(String(init.port));
    }, [isOpen, defaultCharacterName, lastAttempt]);

    const handleConnect = (e: React.MouseEvent) => {
        e.preventDefault();
        e.stopPropagation();

        const trimmedName = characterName.trim();
        if (trimmedName.length === 0) {
            EventBus.emit(TOAST_REQUESTED, { message: 'Character name is required.', severity: 'warning' });
            return;
        }

        const trimmedHost = host.trim();
        if (trimmedHost.length === 0) {
            EventBus.emit(TOAST_REQUESTED, { message: 'Host is required.', severity: 'warning' });
            return;
        }

        const portNum = Number.parseInt(portText.trim(), 10);
        if (!Number.isFinite(portNum) || portNum < 1 || portNum > 65535) {
            EventBus.emit(TOAST_REQUESTED, { message: 'Port must be a number from 1 to 65535.', severity: 'warning' });
            return;
        }

        if (adminLogin && !adminKey.trim()) {
            EventBus.emit(TOAST_REQUESTED, { message: 'Escribe la clave que muestra la terminal del servidor.', severity: 'warning' });
            return;
        }
        setLastConnectAttempt({
            characterName: trimmedName,
            host: trimmedHost,
            port: portNum,
        });
        setConnectDialogOpen(false);
        EventBus.emit(IN_UI_CONNECT_TO_SERVER, {
            host: trimmedHost,
            port: portNum,
            characterName: trimmedName,
            adminKey: adminLogin ? adminKey.trim() : undefined,
        });
        setAdminKey('');
    };

    if (!isOpen) {
        return null;
    }

    return (
        <DraggableDialog
            title={adminLogin ? 'Administrador' : 'Jugador'}
            position={position}
            id="connect-dialog"
            zIndex={zIndex}
            onBringToFront={onBringToFront}
            onContextMenu={(ev) => {
                ev.preventDefault();
            }}
        >
            <div
                style={{
                    display: 'flex',
                    flexDirection: 'column',
                    gap: '10px',
                    color: 'var(--rpg-parchment)',
                    fontFamily: 'Georgia, serif',
                    fontSize: '14px',
                    minWidth: '280px',
                    paddingBottom: '4px',
                }}
            >
                <label>
                    Character name
                    <input
                        type="text"
                        value={characterName}
                        onChange={(ev) => setCharacterName(ev.target.value)}
                        style={inputStyle}
                        autoComplete="username"
                    />
                </label>
                {adminLogin && (
                    <label>Clave de administrador
                        <input type="password" value={adminKey} autoComplete="off" style={inputStyle}
                            onChange={(e) => setAdminKey(e.target.value)} />
                    </label>
                )}
                <label>
                    Host
                    <input
                        type="text"
                        disabled={adminLogin}
                        value={host}
                        onChange={(ev) => setHost(ev.target.value)}
                        style={inputStyle}
                        autoComplete="off"
                    />
                </label>
                <label>
                    Port
                    <input
                        type="number"
                        min={1}
                        max={65535}
                        disabled={adminLogin}
                        value={portText}
                        onChange={(ev) => setPortText(ev.target.value)}
                        style={inputStyle}
                        autoComplete="off"
                    />
                </label>
                <div style={{ display: 'flex', justifyContent: 'center', flexShrink: 0, paddingTop: '8px' }}>
                    <RpgButton onClick={handleConnect} style={{ width: '140px' }}>
                        Connect
                    </RpgButton>
                </div>
            </div>
        </DraggableDialog>
    );
}
