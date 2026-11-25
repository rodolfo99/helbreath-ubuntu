import { useStore } from '@tanstack/react-store';
import { createPortal } from 'react-dom';
import { TownAction } from '../../proto/generated/network';
import { getItemById } from '../../constants/Items';
import { cameraDialogStore } from '../store/CameraDialog.store';
import { inventoryDialogStore } from '../store/InventoryDialog.store';
import { showTown, townStore } from '../store/Town.store';
import { useFullscreenPortalTarget } from '../hooks/utils';
import { RpgButton } from '../components/RpgButton';

type Props = { act: (action: TownAction, id?: number, uid?: bigint) => void };
export function TownDialog({ act }: Props) {
    const { room, open, pending } = useStore(townStore, state => state);
    const bag = useStore(inventoryDialogStore, state => state.baggedItems);
    const position = useStore(cameraDialogStore, s => s.playerPosition);
    const target = useFullscreenPortalTarget();
    if (!open || !room || !target) return null;
    const money = bag.filter(i => i.itemId === 35).reduce((n, i) => n + (i.quantity ?? 1), 0);
    function bankRow(id: number, uid: bigint, quantity: number, deposit: boolean) {
        const name = getItemById(id)?.name ?? String(id);
        const label = deposit ? 'Depositar' : 'Retirar';
        return <div className="town-row" key={uid.toString()}>
            <span>{name}{quantity > 1 && ` ×${quantity}`}</span>
            <RpgButton disabled={pending} aria-label={`${label} ${name}`}
                onClick={() => act(deposit ? TownAction.TOWN_DEPOSIT : TownAction.TOWN_WITHDRAW, 0, uid)}>{label}</RpgButton>
        </div>;
    }
    return createPortal(<section className="draggable-dialog town-dialog" role="dialog" aria-label={room.title}>
        <div className="draggable-dialog-header">{room.title}</div>
        <div className="town-content">
            {room.service === 'city' || room.service === 'routes' ? <>
                <p>Camina a estas coordenadas. El minimapa marca los servicios en amarillo y las salidas a otros mapas en verde.</p>
                {position.worldX !== undefined && position.worldY !== undefined &&
                    <p>Tu posición <strong>({position.worldX}, {position.worldY})</strong></p>}
                {room.doors.map(door => <div className="town-row" key={door.name}>
                    <span>{door.route ? `Ir a ${door.name}` : door.name}</span><strong>({door.x}, {door.y})</strong>
                </div>)}
            </> : <>
                <p>Oro en la bolsa <strong>{money}</strong></p>
                {room.service === 'bank' ? <>
                    <h3>En la bolsa</h3>
                    {bag.length === 0 && <p>Tu bolsa está vacía.</p>}
                    {bag.map(i => bankRow(i.itemId, BigInt(i.itemUid), i.quantity ?? 1, true))}
                    <h3>En el banco</h3>
                    {room.deposits.length === 0 && <p>Tu depósito está vacío.</p>}
                    {room.deposits.map(i => bankRow(i.itemId, i.itemUid, i.quantity ?? 1, false))}
                </> : <>
                    {room.offers.length === 0 && <p>Ya conoces todos los hechizos disponibles.</p>}
                    {room.offers.map(offer => <div className="town-row" key={offer.id}>
                        <span>{offer.name}<small>{offer.price} de oro</small></span>
                        <RpgButton disabled={pending || money < offer.price}
                            aria-label={`Comprar ${offer.name}`} onClick={() => act(TownAction.TOWN_BUY, offer.id)}>Comprar</RpgButton>
                    </div>)}
                </>}
            </>}
            <p aria-live="polite">{room.notice}</p>
        </div>
        <RpgButton onClick={() => showTown(false)}>Cerrar</RpgButton>
    </section>, target);
}
